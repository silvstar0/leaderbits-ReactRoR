# frozen_string_literal: true

require 'rails_helper'

def fill_in_user_in_360_form
  expect(page).to have_content('360 Team Survey')
  expect(page).not_to have_content('newuser@domain.com')
  click_link 'Add New Person'

  fill_in 'Name', with: 'John'
  fill_in 'Email', with: 'user1@example.com'
  #click_button('Send Survey')
  click_button('Save')

  expect(page).to have_content('John has been added to the team.')

  click_link('Send Survey and Continue')
end

def fill_in_user_in_mentee_form
  expect(page).to have_content('Pick a team member to invite to be your mentee')
  click_link 'Add New Mentee'
  fill_in 'Email', with: 'user1@example.com'
  fill_in 'Name', with: 'John'
  click_button('Save')
end

def click_take_leadership_strength_finder
  expect(body).to include('Take Leadership Strengths Finder')
  page.evaluate_script %($('input[value="Take Leadership Strengths Finder"]').click())
end

def fill_in_strenght_finder_form
  expect(page).to have_content(question.title)
  fill_in question.title, with: 'My Answer'
  click_button 'Submit & Continue'
end

RSpec.describe 'Onboarding', type: :feature, js: true do
  let(:leaderbit) { create(:active_leaderbit) }
  let(:schedule) { Schedule.create!(name: Schedule::GLOBAL_NAME).tap { |schedule| schedule.leaderbit_schedules.create! leaderbit: leaderbit } }
  let!(:survey) { create(:survey, title: 'Leadership Strengths Finder', type: Survey::Types::FOR_LEADER) }
  let!(:question) { create(:single_textbox_question, survey: survey) }

  describe 'Given new leader user with all onboarding steps enabled' do
    let(:user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             can_create_a_mentee: true,
             goes_through_leader_strength_finder_onboarding_step: true,
             goes_through_team_survey_360_onboarding_step: true,
             goes_through_organizational_mentorship_onboarding_step: true,
             schedule: schedule)
    end
    let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

    example do
      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )

      expect_to_see_welcome_page

      expect(page).to have_content('STEP 1 / 4')
      click_take_leadership_strength_finder

      expect(page).to have_content('STEP 2 / 4')
      fill_in_strenght_finder_form

      expect(page).to have_content('Survey data saved')
      expect(page).to have_content('STEP 3 / 4')

      fill_in_user_in_360_form

      expect(page).to have_content('STEP 4 / 4')
      fill_in_user_in_mentee_form

      click_link("Select Mentee & Continue")

      #page.evaluate_script %($('input[value="Begin Your First Challenge"]').click())

      wait_for { current_path }.to eq(leaderbit_path(leaderbit))
      #sleep 2

      expect(page).to have_content leaderbit.name

      expect_leaderbit_start_message
    end

    pending 'must be able to add multiple anonymous survey participants'
  end

  describe 'Given new leader user with all only goes_through_leader_strength_finder_onboarding_step onboarding step enabled' do
    let(:user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             goes_through_leader_strength_finder_onboarding_step: true,
             goes_through_team_survey_360_onboarding_step: false,
             goes_through_organizational_mentorship_onboarding_step: false,
             schedule: schedule)
    end
    let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

    example do
      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )

      expect_to_see_welcome_page

      expect(page).to have_content('STEP 1 / 2')

      click_take_leadership_strength_finder

      expect(page).to have_content(question.title)

      expect(page).to have_content('STEP 2 / 2')

      fill_in question.title, with: 'My Answer'
      click_button 'Submit & Continue'

      wait_for { current_path }.to eq(leaderbit_path(leaderbit))

      expect(page).to have_content leaderbit.name

      expect_leaderbit_start_message
    end
  end

  #TODO restore this spec when you find a workaround to scroll vimeo play indicator closer to end
  # describe 'Given new leader user with only goes_through_leader_welcome_video_onboarding_step enabled' do
  #   let(:user) do
  #     create(:user,
  #            seen_welcome_video_for_leaders: false,
  #            goes_through_leader_welcome_video_onboarding_step: true,
  #            goes_through_leader_strength_finder_onboarding_step: false,
  #            goes_through_team_survey_360_onboarding_step: false,
  #            goes_through_organizational_mentorship_onboarding_step: false,
  #            schedule: schedule)
  #   end
  #   let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }
  #
  #   example do
  #     visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )
  #
  #     expect_to_see_welcome_page
  #     expect(body).to include('Begin Your First Challenge')
  #
  #     page.evaluate_script %($('input[value="Begin Your First Challenge"]').click())
  #
  #     wait_for { current_path }.to eq(leaderbit_path(leaderbit))
  #
  #     expect(page).to have_content leaderbit.name
  #
  #     expect_leaderbit_start_message
  #   end
  # end

  describe 'Given new leader user with all only goes_through_team_survey_360_onboarding_step onboarding step enabled' do
    let(:user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             goes_through_leader_strength_finder_onboarding_step: false,
             goes_through_team_survey_360_onboarding_step: true,
             goes_through_organizational_mentorship_onboarding_step: false,
             schedule: schedule)
    end
    let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

    example do
      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )

      expect_to_see_welcome_page
      expect(body).to include('Send 360 Team Survey')
      expect(page).to have_content('STEP 1 / 2')

      page.evaluate_script %($('input[value="Send 360 Team Survey"]').click())

      expect(page).to have_content('STEP 2 / 2')

      fill_in_user_in_360_form

      #fill_in question.title, with: 'My Answer'
      #click_button 'Submit & Continue'

      wait_for { current_path }.to eq(leaderbit_path(leaderbit))

      expect(page).to have_content leaderbit.name

      expect_leaderbit_start_message
    end
  end

  describe 'Given new leader user with all only goes_through_leader_strength_finder_onboarding_step and goes_through_team_survey_360_onboarding_step onboarding steps enabled' do
    let(:user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             goes_through_leader_strength_finder_onboarding_step: true,
             goes_through_team_survey_360_onboarding_step: true,
             goes_through_organizational_mentorship_onboarding_step: false,
             schedule: schedule)
    end
    let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

    example do
      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )

      expect_to_see_welcome_page
      expect(page).to have_content('STEP 1 / 3')

      click_take_leadership_strength_finder


      expect(page).to have_content('STEP 2 / 3')
      fill_in_strenght_finder_form

      expect(page).to have_content('STEP 3 / 3')
      fill_in_user_in_360_form

      wait_for { current_path }.to eq(leaderbit_path(leaderbit))

      expect(page).to have_content leaderbit.name

      expect_leaderbit_start_message
    end
  end

  describe 'Given new leader user with all only goes_through_organizational_mentorship_onboarding_step onboarding step enabled' do
    let(:user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             goes_through_leader_strength_finder_onboarding_step: false,
             goes_through_team_survey_360_onboarding_step: false,
             goes_through_organizational_mentorship_onboarding_step: true,
             can_create_a_mentee: true,
             schedule: schedule)
    end
    let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

    example do
      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: user.authentication_token )

      expect_to_see_welcome_page
      expect(body).to include('Select Mentee')
      expect(page).to have_content('STEP 1 / 2')

      page.evaluate_script %($('input[value="Select Mentee"]').click())

      expect(page).to have_content('STEP 2 / 2')

      fill_in_user_in_mentee_form

      click_link("Select Mentee & Continue")

      wait_for { current_path }.to eq(leaderbit_path(leaderbit))

      expect(page).to have_content leaderbit.name

      expect_leaderbit_start_message
    end
  end
end
