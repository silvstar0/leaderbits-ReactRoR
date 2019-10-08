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

# This model is used for tracking/logging successfully sent "User monthly progress" emails.
# The goal is transparency, flexibility and confidence that we don't send same email multiple times
class UserSentWeeklyTeamProgressReport < UserSentEmail
  alias_attribute :team, :resource

  validates :resource, presence: true
  validate :validate_resource_type

  def human_description(*)
    %(Weekly team report - #{team.name})
  end

  def visible_in_engagement?
    true
  end

  private

  def validate_resource_type
    return if errors[:resource].present?
    return if resource_type.to_s == Team.to_s

    errors.add(:resource_type, :invalid)
  end
end
