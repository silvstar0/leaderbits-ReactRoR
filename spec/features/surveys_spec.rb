# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Surveys', type: :feature, js: true do
  let!(:survey) { create(:survey, type: Survey::Types::FOR_FOLLOWER, anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT, title: 'Anonymous feedback on how you view %{name} as a leader') }

  let!(:anonymous_survey_participant) { create(:anonymous_survey_participant, role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT) }
  let!(:question1) { create(:single_textbox_question, survey: survey) }

  describe 'anonymous survey' do
    example do
      visit participate_anonymously_survey_path(survey, anonymous_survey_participant_id: anonymous_survey_participant.uuid)

      expect(page).to have_content('Anonymous feedback on how you view')
      expect(page).to have_content(question1.title)

      fill_in question1.title, with: 'My answer'
      click_button 'Submit'

      expect(page).to have_content('Thank you')
    end
  end
end
