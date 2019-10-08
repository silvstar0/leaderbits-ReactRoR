# frozen_string_literal: true

class WebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token, only: %i[postmark_bounce]

  def postmark_bounce
    logger.info "Received #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}."
    logger.info params.inspect

    #NOTE: Rails.env is not a reliable way to identify environment here because
    #webhook on staging & production are the the same.
    slack_notify "Postmark *BOUNCE* event\n#{JSON.pretty_generate request.params}"

    head :ok
  end
end
