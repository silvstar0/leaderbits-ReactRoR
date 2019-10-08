# frozen_string_literal: true

# == Schema Information
#
# Table name: progress_report_recipients
#
#  id               :bigint(8)        not null, primary key
#  frequency        :string           not null
#  added_by_user_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#

class ProgressReportRecipient < ApplicationRecord
  belongs_to :added_by_user, class_name: 'User', touch: true
  belongs_to :user, touch: true

  module Frequencies
    WEEKLY = 'weekly'
    BIMONTHLY = 'bi_monthly'
    MONTHLY = 'monthly'

    ALL = [
      WEEKLY,
      BIMONTHLY,
      MONTHLY
    ].freeze
  end

  enum frequency: ProgressReportRecipient::Frequencies::ALL.each_with_object({}) { |v, h| h[v] = v }

  validates :user, uniqueness: { scope: :added_by_user }

  validates :frequency, inclusion: { in: Frequencies::ALL }, allow_nil: false, allow_blank: false

  after_destroy :user_is_trying_to_hide, if: :trying_to_hide_notification_enabled?

  def email
    user ? user.email : nil
  end

  def name
    user ? user.name : nil
  end

  private

  def user_is_trying_to_hide
    AccountabilityMailer
      .with(user: added_by_user, recipient_name: user.name, recipient_email: user.email)
      .user_is_trying_to_hide
      .deliver_now
  end

  def trying_to_hide_notification_enabled?
    added_by_user.notify_observer_if_im_trying_to_hide?
  end
end
