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

# This model is used for tracking/logging successfully sent "User lifetime progress dump" emails.
# The goal is transparency, flexibility and confidence that we don't send same email multiple times
class UserSentProgressDump < UserSentEmail
  audited

  validates :resource, absence: true

  def human_description(*)
    %(Personal Lifetime progress report)
  end

  def visible_in_engagement?
    false
  end
end
