# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                                                                                                              :bigint(8)        not null, primary key
#  name                                                                                                            :string           not null
#  created_at                                                                                                      :datetime         not null
#  updated_at                                                                                                      :datetime         not null
#  first_leaderbit_introduction_message                                                                            :text
#  hour_of_day_to_send                                                                                             :integer          default(9)
#  day_of_week_to_send                                                                                             :string           default("Monday")
#  discarded_at                                                                                                    :datetime
#  custom_default_schedule_id                                                                                      :integer
#  leaderbits_sending_enabled                                                                                      :boolean          default(TRUE), not null
#  stripe_customer_id                                                                                              :string
#  active_since(needed in cases when organization is created prematurely but it must be activated on certain date) :datetime         not null
#  users_count                                                                                                     :integer
#

class Organization < ApplicationRecord
  include Discard::Model

  module IntercomAccountTypes
    #do no rename these values so that Intercom stays relevant and sortable/searchable
    ENTERPRISE = 'enterprise'
    INDIVIDUAL = 'individual'
  end

  #TODO
  #should we rename field leaderbits_sending_enabled?
  #becuase it is no longer about leaderbits sending only
  # don't quit keep going is also using it

  has_associated_audits
  audited

  has_one_attached :logo, acl: :public

  belongs_to :custom_default_schedule, optional: true
  has_many :users
  has_many :teams, dependent: :destroy

  before_validation do
    self.stripe_customer_id = nil if stripe_customer_id.blank?
  end

  validates :name, presence: true, uniqueness: true, allow_nil: false, allow_blank: false

  validates :hour_of_day_to_send, inclusion: { in: 0..23 }
  validates :day_of_week_to_send, inclusion: { in: Date::DAYNAMES }

  #extracted to its own scope because existing "missing" introducing fields are "", not nil.
  scope :present_first_leaderbit_introduction_message, -> { where.not(first_leaderbit_introduction_message: [nil, '']) }
  scope :missing_first_leaderbit_introduction_message, -> { where(first_leaderbit_introduction_message: [nil, '']) }

  validates :stripe_customer_id, uniqueness: true, allow_nil: true, allow_blank: false

  after_save :invalidate_users_cache

  def to_param
    [id, name.parameterize].join("-")
  end

  # #167149083
  def activity_report_becomes_available_at
    2.months.since(created_at)
  end

  # a bit of history:
  # before 2019 it was a separate db field which admin had to explicitely set
  # but data was very inaccurate so guessing by number of users is better than it was
  # If you ever need to bring it back start with getting the actual and valid list of orgs <=> types
  def account_type
    count = User.where.not(schedule_id: nil).where(organization_id: id).count

    count > 1 ? IntercomAccountTypes::ENTERPRISE : IntercomAccountTypes::INDIVIDUAL
  end

  def enterprise?
    account_type == IntercomAccountTypes::ENTERPRISE
  end

  def individual?
    account_type == IntercomAccountTypes::INDIVIDUAL
  end

  # @return [Hash]
  def intercom_custom_data
    {
      name: name,
      created_at: created_at
    }
  end

  # @return [LeaderbitLog]
  def lifetime_completed_leaderbit_logs
    LeaderbitLog
      .completed
      .where('users.organization_id = ?', id)
      .joins(:user)
      .includes(:leaderbit)
      .order(updated_at: :desc)
  end

  # @return [Stripe::Card] or nil
  def default_card
    return if stripe_customer.blank?

    @default_card ||= stripe_customer.sources.all(object: "card").detect { |x| x[:id] == stripe_customer.default_source }
  end

  # @return [Stripe::Customer] or nil
  def stripe_customer
    @stripe_customer ||= stripe_customer_id ? Stripe::Customer.retrieve(stripe_customer_id) : nil
  end

  private

  # This method is needed for proper intercom user-syncing
  # updates to org trigger updates to user profiles
  def invalidate_users_cache
    reload.users.map(&:touch)
  end
end
