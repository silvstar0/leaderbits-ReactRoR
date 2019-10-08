# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  describe "GET #strength_levels" do
    login_user
    render_views

    example '', login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      get :strength_levels

      expect(response).to be_successful
      expect(response.body).to have_content('Select what areas you are strongest in')
    end
  end

  describe "GET #analytics" do
    login_user
    render_views

    example '', login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      get :analytics

      expect(response).to be_successful
      expect(response.body).to have_content('Watch your momentum to get point multipliers.')
    end
  end

  describe "GET #community" do
    login_user
    render_views

    example '', login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      get :community

      expect(response).to be_successful
      expect(response.body).to have_content('How the community works')
    end
  end
end
