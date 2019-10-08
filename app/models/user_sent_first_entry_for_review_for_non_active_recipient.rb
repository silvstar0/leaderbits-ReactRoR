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

# This model is needed as a workaround, for mentors(leaderbits_sending_enabled=false) of NTC Elite organization and Tealium
# as their 1st email that will sign them in
class UserSentFirstEntryForReviewForNonActiveRecipient < UserSentEmail
  validates :user, uniqueness: { scope: :type }

  def human_description(current_user:)
    suffix = if current_user.system_admin? || current_user.leaderbits_employee_with_access_to_any_organization?
               "(recipient is not an active LeaderBits recipient)"
             else
               ''
             end
    "New entry for you to review#{suffix}"
  end

  def visible_in_engagement?
    true
  end
end
