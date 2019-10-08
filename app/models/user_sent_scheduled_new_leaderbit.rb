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

# This model is used for tracking/logging successfully sent leaderbits and comparing it with the expected number of leaderbits to be sent
# Requested by Joel as a way to add transparency and visibility into current status of leaderbits sending.
class UserSentScheduledNewLeaderbit < UserSentEmail
  alias_attribute :leaderbit, :resource

  validates :resource, presence: true
  validate :validate_resource_type

  def human_description(current_user:)
    # because there is also manual sending and we need to distinguish both types
    if current_user.system_admin? || current_user.leaderbits_employee_with_access_to_any_organization?
      %(Scheduled New LeaderBit #{resource.name})
    else
      %(New LeaderBit #{resource.name})
    end
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
