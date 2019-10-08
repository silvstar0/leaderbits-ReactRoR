# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AchievementsController, type: :controller do
  describe "GET #show" do
    login_user

    context 'given user with points' do
      render_views
      it "returns achievement unlocked modal", login_factory: [:team_member_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        create(:point, user: @user)

        get :show, params: { type: "achievement|1" }, xhr: true

        expect(response).to be_successful
        expect(response.body).to include('achievement-unlocked-reveal-container')
      end
    end
  end
end
