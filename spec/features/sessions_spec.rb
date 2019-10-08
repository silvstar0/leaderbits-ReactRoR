# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :feature, js: true do
  context 'given deleted/disabled/discarded user account' do
    it 'prevents users from signing in' do
      user = create(:user, password: 'Password1')
      user.discard

      expect_account_is_locked_while_logging_in email: user.email, password: 'Password1'
    end
  end

  context 'given *technical* user who was created without password' do
    it 'prevents users from signing in with blank password' do
      user = User.new(email: Faker::Internet.email,
                      name: Faker::Name.name,
                      #technically these users don't need timezones at all
                      time_zone: ActiveSupport::TimeZone.all.sample.name,
                      goes_through_leader_welcome_video_onboarding_step: false,
                      goes_through_leader_strength_finder_onboarding_step: false,
                      goes_through_team_survey_360_onboarding_step: false,
                      goes_through_organizational_mentorship_onboarding_step: false,
                      hour_of_day_to_send: 8,
                      day_of_week_to_send: 'Monday',
                      organization: create(:organization))

      def user.password_required?
        false
      end
      user.save!

      #NOTE purposely not discarded because that's not what we're testing here

      visit root_path

      fill_in 'Email', with: user.email
      #fill_in 'Password', with: 'Password1'

      click_button 'Log in'

      expect(page).to have_content "Invalid Email or password"
    end
  end

  context 'given valid user account' do
    it 'lets him in' do
      user = create(:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false)

      visit root_path

      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'Password1'

      click_button 'Log in'

      expect_being_logged_in user
    end
  end

  context 'given signed in user' do
    it 'can sign out' do
      user = create(:user,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false)
      login_as(user, scope: :user, run_callbacks: false)

      visit root_path

      sign_out_as(user)

      expect(page).to have_content 'Forgot your password'
    end
  end
end
