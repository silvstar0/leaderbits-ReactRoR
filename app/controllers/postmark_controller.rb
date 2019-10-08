# frozen_string_literal: true

class PostmarkController < ActionController::Base
  #before_action :authenticate_user!

  def show
    message_id = params.fetch(:message_id)

    client = Postmark::ApiClient.new ENV.fetch('POSTMARK_API_TOKEN')
    @message = client.get_message(message_id)
  end
end
