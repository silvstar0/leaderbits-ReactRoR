# frozen_string_literal: true

# == Schema Information
#
# Table name: user_sent_emails
#
#  id            :bigint(8)        not null, primary key
#  user_id       :bigint(8)        not null
#  resource_id   :bigint(8)
#  created_at    :datetime         not null
#  resource_type :string
#  type          :string
#  params        :json
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class UserSentIncompleteLeaderbitReminder < UserSentEmail
  alias_attribute :leaderbit, :resource

  validates :resource, presence: true
  validate :validate_resource_type

  validates :resource_id, uniqueness: { scope: :user }

  def human_description(*)
    %(Reminder about incomplete LeaderBit #{resource.name})
  end

  def visible_in_engagement?
    true
  end

  private

  def validate_resource_type
    return if errors[:resource].present?
    return if resource_type.to_s == Leaderbit.to_s

    errors.add(:resource_type, :invalid)
  end
end
