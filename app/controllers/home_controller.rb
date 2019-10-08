# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:robots]

  skip_before_action :verify_authenticity_token, only: %i[robots]
  skip_before_action :ensure_all_onboarding_steps_completed_for_active_recipient, only: %i[robots]

  # if that's leader sign up procedure, think of it as STEP 1 of multi-step sign up form with surveys and mentee
  #NOTE: keep in sync with #ensure_all_onboarding_steps_completed_for_active_recipient method
  def welcome_video
    authenticate_in_action_cable

    respond_to do |format|
      format.html { render layout: 'survey' }
    end
  end

  def robots
    render plain: File.read(Rails.root.join("config/robots.#{Rails.env}.txt"))
  end

  def root
    leaderbit = current_user.current_leaderbit_in_progress
    if leaderbit.present?
      redirect_to leaderbit_path(leaderbit)
      return
    end

    redirect_to dashboard_path
  end

  def dashboard
    # because dashboard is for real typical leaderbit users
    redirect_to entry_groups_path unless current_user.leaderbits_sending_enabled?
  end
end
