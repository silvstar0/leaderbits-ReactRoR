# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update]

  #NOTE: why this approach(current/last step indicating via AJAX) was used because
  # 1) welcome video step can be marked as completed only after watching the whole video(search for "onPlayProgress")
  # 2) Nick wanted it to keep simple and consistent on all the steps
  def update
    last_seen_url = params.fetch(:last_seen_url)
    #example: "http://localhost:3000/welcome"
    #document.location.href

    step = url_to_onboarding_step last_seen_url

    #FIXME explicitely set to welcome video instead?
    #FIXME or move to track video job instead?
    current_user.update_last_completed_onboarding_step step

    head :ok
  end
end
