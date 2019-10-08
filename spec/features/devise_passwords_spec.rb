# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Passwords', type: :feature, js: true do
  context 'given existing user with some password previously set' do
    it 'allows user to request resetting forgotten password', skip: ENV['CI'].present? do
      user = build(:user,
                   leaderbits_sending_enabled: false,
                   password: '',
                   encrypted_password: '')

      def user.password_required?
        false
      end
      user.save!

      request_forgot_password_and_set_new_password(email: user.email, new_password: 'abcdef')

      visit root_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'abcdef'
      click_button('Log in')

      expect_being_logged_in user
    end
  end

  context 'given discarded user' do
    it 'allows to reset password but prevents from signing in' do
      user = create(:user)
      user.discard

      request_forgot_password_and_set_new_password(email: user.email, new_password: 'abcdef')

      expect_account_is_locked_while_logging_in(email: user.email, password: 'abcdef')
    end
  end

  context 'given existing user with blank password' do
    it 'allows user to request resetting forgotten password' do
      user = create(:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false)

      #user_can_reset_password_via_forgot_password user
      request_forgot_password_and_set_new_password(email: user.email, new_password: 'abcdef')

      visit root_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'abcdef'
      click_button('Log in')

      expect_being_logged_in user
    end
  end

  describe 'reset password form' do
    it 'given invalid token displays an error' do
      visit edit_user_password_path(reset_password_token: 'foo')

      fill_in 'New password', with: "bar"
      fill_in 'Confirm your new password', with: "bar"
      click_button 'Change my password'

      expect(page).to have_content "Reset password token is invalid"
    end
  end

  def request_forgot_password_and_set_new_password(email:, new_password:)
    visit root_path

    click_link 'Forgot your password?'

    fill_in 'Email', with: email

    click_button 'Send me reset password instructions'

    expect(page).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."

    first_email_sent_to(email)

    current_email.click_link 'Set a new password'

    fill_in 'New password', with: new_password
    fill_in 'Confirm your new password', with: new_password

    click_button 'Change my password'

    expect(page).to have_content("Your password has been changed successfully")
  end
end
