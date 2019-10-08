# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Your Profile', type: :feature, js: true do
  let(:organization) { create(:organization, active_since: 3.weeks.ago) }

  it 'can update own profile data' do
    @user = create(:user,
                   organization: organization,
                   goes_through_leader_welcome_video_onboarding_step: false,
                   goes_through_leader_strength_finder_onboarding_step: false,
                   goes_through_team_survey_360_onboarding_step: false,
                   goes_through_organizational_mentorship_onboarding_step: false)
    login_as(@user, scope: :user, run_callbacks: false)

    open_your_profile

    wait_for { body }.to include(@user.name)

    within '.edit_user' do
      fill_in 'Name', with: 'My New Name'
      click_button('Save')
    end

    wait_for { body }.to include('My New Name')
    expect(body).not_to include @user.name
  end

  describe 'Setting password' do
    context 'given user with some existing password' do
      let(:current_password) { 'YMMVYMMV' }

      before do
        @user = create(:user,
                       password: current_password,
                       organization: organization,
                       goes_through_leader_welcome_video_onboarding_step: false,
                       goes_through_leader_strength_finder_onboarding_step: false,
                       goes_through_team_survey_360_onboarding_step: false,
                       goes_through_organizational_mentorship_onboarding_step: false)
        login_as(@user, scope: :user, run_callbacks: false)
      end

      context 'given all fields as invalid' do
        example do
          open_your_profile

          within '.edit_password' do
            fill_in 'Current password', with: 'zzz'
            fill_in 'New password', with: 'foo'
            fill_in 'Confirm your new password', with: 'bar'

            click_button('Save')
          end

          expect(page).to have_content('is invalid')
          expect(page).to have_content('is too short')
          expect(page).to have_content('doesn\'t match Password')
        end
      end

      context 'given all new password as empty' do
        # @see https://github.com/plataformatec/devise/issues/2349
        it 'prevents password update if password was set to blank' do
          open_your_profile

          within '.edit_password' do
            fill_in 'Current password', with: current_password
            fill_in 'New password', with: ''
            fill_in 'Confirm your new password', with: ''

            click_button('Save')
          end

          expect(page).not_to have_content('Password successfully updated')
          expect(page).to have_content("can't be blank")
        end
      end

      context 'given all fields as valid' do
        it 'updates password and let you sign in' do
          open_your_profile

          within '.edit_password' do
            fill_in 'Current password', with: current_password
            fill_in 'New password', with: 'foobar'
            fill_in 'Confirm your new password', with: 'foobar'

            click_button('Save')
          end

          expect(page).not_to have_content('is invalid')
          expect(page).not_to have_content('is too short')
          expect(page).not_to have_content('doesn\'t match Password')

          expect(page).to have_content('Password successfully updated')

          sign_out_as(@user)

          visit root_path
          fill_in 'Email', with: @user.email
          fill_in 'Password', with: 'foobar'
          click_button 'Log in'

          expect_being_logged_in @user
        end
      end
    end

    context 'given user with some existing password' do
      before do
        @user = User.new(email: 'foo@bar.com',
                         name: Faker::Name.name,
                         time_zone: ActiveSupport::TimeZone.all.sample.name,
                         organization: create(:organization, active_since: 3.weeks.ago),
                         hour_of_day_to_send: 8,
                         day_of_week_to_send: 'Monday',
                         goes_through_leader_welcome_video_onboarding_step: false,
                         goes_through_leader_strength_finder_onboarding_step: false,
                         goes_through_team_survey_360_onboarding_step: false,
                         goes_through_organizational_mentorship_onboarding_step: false,
                         schedule: create(:schedule))

        def @user.password_required?
          false
        end
        @user.save!
      end

      example do
        login_as(@user, scope: :user, run_callbacks: false)

        open_your_profile

        within '.edit_password' do
          fill_in 'New password', with: 'foobar'
          fill_in 'Confirm your new password', with: 'foobar'

          click_button('Save')
        end

        expect(page).to have_content("Password successfully updated")
      end
    end
  end

  describe 'Resetting password' do
    before do
      @user = create(:user,
                     organization: organization,
                     goes_through_leader_welcome_video_onboarding_step: false,
                     goes_through_leader_strength_finder_onboarding_step: false,
                     goes_through_team_survey_360_onboarding_step: false,
                     goes_through_organizational_mentorship_onboarding_step: false)
      login_as(@user, scope: :user, run_callbacks: false)
    end

    example do
      open_your_profile

      expect(page).to have_content('Forgot password?')
      expect(page).to have_content("Click here")
      expect(page).to have_content("and we'll send you a link to reset your password.")

      click_link 'Click here'

      expect(page).to have_content('You will receive an email with instructions about how to reset your password in a few minutes')
    end
  end

  describe 'Vacation Mode' do
    context 'given regular user' do
      before do
        @user = create(:user,
                       goes_through_leader_welcome_video_onboarding_step: false,
                       goes_through_leader_strength_finder_onboarding_step: false,
                       goes_through_team_survey_360_onboarding_step: false,
                       goes_through_organizational_mentorship_onboarding_step: false)
        login_as(@user, scope: :user, run_callbacks: false)
      end

      it 'can enable vacation mode', skip: ENV['CI'].present? do
        open_your_profile

        within '#new_vacation_mode' do
          fill_in "What's happening?", with: 'Traveling to Brazil'
          click_button('Save')
        end

        expect(page).to have_content('Vacation mode successfully')
      end
    end

    context 'given user with upcoming vacation mode' do
      before do
        @user = create(:user,
                       goes_through_leader_welcome_video_onboarding_step: false,
                       goes_through_leader_strength_finder_onboarding_step: false,
                       goes_through_team_survey_360_onboarding_step: false,
                       goes_through_organizational_mentorship_onboarding_step: false)
        login_as(@user, scope: :user, run_callbacks: false)
      end

      it 'can update vacation mode', skip: ENV['CI'].present? do
        create(:vacation_mode, user: @user, starts_at: Time.now.beginning_of_day, ends_at: 7.days.from_now.end_of_day, reason: 'Hello World')

        open_your_profile
        sleep 1 # do not remove because
        press 'Edit' #not click because it is reveal-toggle zurb component

        fill_in "What's happening?", with: 'Updated Updated'
        sleep 0.1
        #sleep 5
        click_button('Update')

        expect(page).to have_content('Vacation mode successfully')

        expect(page).to have_content('Updated Updated')
        expect(page).not_to have_content('Hello World')
      end

      it 'can destroy vacation mode' do
        create(:vacation_mode, user: @user, starts_at: Time.now.beginning_of_day, ends_at: 7.days.from_now.end_of_day, reason: 'Hello World')

        open_your_profile
        within('#vacation-modes-container') do
          page.accept_confirm { click_link 'Destroy' }
        end

        expect(page).to have_content('Vacation mode successfully')
        expect(page).not_to have_content('Hello World')
      end
    end
  end
end
