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

class UserSentInvitationToBecomeMentee < UserSentEmail
  alias_attribute :organizational_mentorship, :resource

  validates :resource, presence: true
  validate :validate_resource_type

  def human_description(*)
    if resource.blank?
      # because mentorship record has been deleted - we no longer know his name
      return "Invitation to become a mentee."
    end

    sent_by = User.find(organizational_mentorship.mentor_user_id)
    %(Invitation to become a mentee. Mentor #{sent_by.name})
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
