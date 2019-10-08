# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  describe "POST #create" do
    login_user
    render_views

    example '', login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: true, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      survey = create(:survey, type: Survey::Types::FOR_LEADER)
      question = create(:single_textbox_question, survey: survey)

      expect {
        post :create, params: { answers: { question.id => "There we go!" }, survey_id: survey.id }
      }.to change(Answer, :count).to(1)

      expect(response).to be_redirect
    end
  end
end
