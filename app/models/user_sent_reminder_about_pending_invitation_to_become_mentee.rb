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

class UserSentReminderAboutPendingInvitationToBecomeMentee < UserSentEmail
  alias_attribute :organizational_mentorship, :resource

  validates :resource, presence: true
  validate :validate_resource_type

  def human_description(*)
    sent_by = User.find resource.mentor_user_id
    %(Reminder about pending invitation to become a mentee. Mentor #{sent_by.name})
  end

  def visible_in_engagement?
    false
  end

  private

  def validate_resource_type
    return if errors[:resource].present?
    return if resource_type.to_s == OrganizationalMentorship.to_s

    errors.add(:resource_type, :invalid)
  end
end
