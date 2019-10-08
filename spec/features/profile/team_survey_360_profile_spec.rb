# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '360 Team Survey', type: :feature, js: true do
  before do
    @user = create(:user,
                   goes_through_leader_welcome_video_onboarding_step: false,
                   goes_through_leader_strength_finder_onboarding_step: false,
                   goes_through_team_survey_360_onboarding_step: false,
                   goes_through_organizational_mentorship_onboarding_step: false)
    #TODO abstract/DRY this login_as helper call. It is duplicated everywhere
    login_as(@user, scope: :user, run_callbacks: false)

    visit root_path

    mouseover_top_menu_item @user.first_name
  end

  it 'can add new participant' do
    click_link '360 Team Survey'

    expect(page).not_to have_content('user1@example.com')

    expect(page).to have_content("Here's everyone at your team")

    click_link 'Add New Person'

    fill_in 'Name', with: 'John'
    fill_in 'Email', with: 'user1@example.com'
    click_button('Save')

    expect(page).to have_content("John has been added to the team")
    expect(page).to have_content("Here's everyone at your team")
    expect(page).to have_content("Survey Anonymous Results")
    expect(page).to have_content("We will show the results once at least 2 people answered.")

    expect(body).to include('user1@example.com')
    expect(body).to include('John')
  end

  pending 'can update participant'
  pending 'delete participant'

  describe 'display results of anonymous survey' do
    let(:current_user) { create(:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false) }

    let!(:survey) do
      create(:survey,
             title: 'Anonymous feedback on how you view your leader',
             type: Survey::Types::FOR_FOLLOWER,
             anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT)
    end

    let!(:anonymous_survey_participant1) { create(:anonymous_survey_participant, added_by_user: current_user) }
    let!(:anonymous_survey_participant2) { create(:anonymous_survey_participant, added_by_user: current_user) }
    let!(:question1) { create(:slider_question, anonymous_survey_similarity_uuid: 'abc', survey: survey) }
    let!(:question2) { create(:slider_question, anonymous_survey_similarity_uuid: 'def', survey: survey) }

    before do
      login_as(current_user, scope: :user, run_callbacks: false)
    end

    example do
      question1.answers.create!(anonymous_survey_participant: anonymous_survey_participant1, params: { value: 1 })
      question2.answers.create!(anonymous_survey_participant: anonymous_survey_participant1, params: { value: 9 })

      question1.answers.create!(anonymous_survey_participant: anonymous_survey_participant2, params: { value: 2 })
      question2.answers.create!(anonymous_survey_participant: anonymous_survey_participant2, params: { value: 4 })

      visit profile_team_survey_360_path

      expect(page).to have_content('Survey Anonymous Results')
      expect(page).to have_content('Person 1')
      expect(page).to have_content('Person 2')
    end
  end
end
