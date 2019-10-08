# frozen_string_literal: true

# @see https://github.com/intercom/intercom-rails#deleting-your-users
# NOTE: that not all users have intercom account, only valid leaders/leaderbit recipients
class DeleteFromIntercom < ApplicationJob
  def perform(email)
    user = intercom_client.users.find(email: email)
    intercom_client.users.delete(user)
  rescue Intercom::ResourceNotFound => e
    Rails.logger.info e
    Rollbar.scoped(email: email) do
      Rollbar.info(e)
    end
  end
end
