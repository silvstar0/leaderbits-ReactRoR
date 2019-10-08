# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    login_user
    render_views

    context 'team member looking at his own progress' do
      example "", login_factory: [:team_member_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        leaderbit = create(:active_leaderbit)
        create(:leaderbit_log, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit, user: @user, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)
        entry = create(:entry, discarded_at: nil, user: @user, leaderbit: leaderbit)

        get :show, params: { id: @user.to_param }
        aggregate_failures do
          expect(response).to be_successful

          expect(response.body).to have_content("Track your growth")
          expect(response.body).to have_content("Momentum")
          expect(response.body).to have_content(entry.content)
        end
      end
    end

    context "trying to look at other user progress at team member" do
      it "is not allowed unless they both share the same team", login_factory: [:team_member_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        expect {
          get :show, params: { id: create(:user, organization: @user.organization).uuid }
        }.to raise_error(Pundit::NotAuthorizedError, /not allowed to show/)
      end
    end
  end
end
