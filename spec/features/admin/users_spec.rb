# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Users", type: :feature, js: true do
  before do
    @user = create(:system_admin_user)
    login_as(@user, scope: :user, run_callbacks: false)
  end

  describe 'show page' do
    let(:leaderbit) { create(:active_leaderbit) }
    let(:schedule_with_some_leaderibts) do
      create(:schedule, name: Schedule::GLOBAL_NAME).tap do |schedule|
        schedule.leaderbit_schedules.create! leaderbit: leaderbit
      end
    end

    it 'allows to update user notes' do
      user = create(:user, admin_notes: nil)

      visit admin_user_path(user)

      press 'Admin Notes'

      expect(body).not_to have_content('My Notes')

      within('[action="/admin/user-notes"]') do
        fill_in('content', with: 'My Notes')

        sleep 2 # text_area is saved every second
      end

      visit admin_user_path(user)
      expect(body).to have_content('My Notes')
    end

    it 'allows to *Trigger Instant Send*' do
      user = create(:user, schedule: schedule_with_some_leaderibts, discarded_at: nil, admin_notes: nil)

      visit admin_user_path(user)

      page.accept_confirm do
        click_link 'Trigger Instant Send'
      end

      expect(body).to have_content("#{leaderbit.name} has just been sent to #{user.name}")
    end
  end

  describe 'creation of new user' do
    let!(:organization) { create(:organization) }
    let!(:schedule) { create(:schedule, name: Schedule::GLOBAL_NAME) }

    example do
      visit admin_organization_path(organization.to_param)

      click_link 'New User'

      fill_in('Name', with: 'Name1')
      fill_in('Email', with: 'user@domain.com')

      #fill_in('Password', with: 'abcdef', match: :prefer_exact)
      #fill_in('Password confirmation', with: 'abcdef')

      check("C-Level")

      select(schedule.name, from: 'Schedule')

      click_button('Create User')

      expect(page).to have_content 'User successfully created'
      expect(page).to have_content('Name1')

      expect(body).to have_content('Roles')
      expect(body).to have_content('C-Level')

      visit current_path # reload # show page

      expect(body).to have_content('Name1')
    end
  end

  describe 'Edit page' do
    context 'given LeaderBits organization' do
      let!(:organization) { create(:organization, name: 'LeaderBits') }
      let!(:organization2) { create(:organization) }

      it 'allows to update profile info and mark user as official employee' do
        user = create(:user, organization: organization, c_level: false)

        visit edit_admin_user_path(user)

        fill_in('Name', with: 'Elon Musk')
        check("C-Level")
        check(organization2.name) # Employee

        click_button('Update User')

        visit admin_user_path(user.to_param)

        expect(body).to have_content('Elon Musk')
        expect(body).to have_content('Roles')

        expect(body).to have_content('C-Level')
        expect(body).to have_content("employee in #{organization2.name}")
      end
    end

    context 'given random organization' do
      let!(:organization) { create(:organization) }

      it 'allows to update basic profile info' do
        user = create(:user, c_level: false)

        visit edit_admin_user_path(user)

        fill_in('Name', with: 'Elon Musk')
        check("C-Level")

        #check(organization.name) # Employee

        click_button('Update User')

        visit admin_user_path(user.to_param)

        expect(body).to have_content('Elon Musk')
        expect(body).to have_content('Roles')

        expect(body).to have_content('C-Level')
        expect(body).not_to have_content("employee")
      end
    end
  end

  describe 'add leaderbit to Instant Queue queue' do
    let(:user) { create(:user, personalized_leaderbits_algorithm_instead_of_regular_schedule: false, organization: @user.organization) }
    let(:leaderbit1) { create(:active_leaderbit) }
    let(:leaderbit2) { create(:active_leaderbit) }
    let(:leaderbit3) { create(:active_leaderbit) }

    example do
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit2
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit3

      visit admin_user_path(user.to_param)

      expect(body).to include "Next LeaderBit to receive: #{leaderbit1.name}"

      find("##{Rails.configuration.add_to_next_up_select_dom_id}").select(leaderbit3.name)

      click_button("Add to Instant Queue")
      expect(page).to have_content "#{leaderbit3.name} has just been added to the Instant Queue for #{user.name}"

      expect(body).to include "Next LeaderBit to receive: #{leaderbit3.name}"
      #sleep 5
      #expect(page).to have_content "Received at"
    end
  end

  describe 'remove leaderbit from Instant queue' do
    let(:user) { create(:user, personalized_leaderbits_algorithm_instead_of_regular_schedule: false, organization: @user.organization) }
    let(:leaderbit1) { create(:active_leaderbit) }
    let(:leaderbit2) { create(:active_leaderbit) }
    let(:leaderbit3) { create(:active_leaderbit) }

    example do
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit2
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit3

      user.preemptive_leaderbits.create! leaderbit: leaderbit3, added_by_user: @user

      visit admin_user_path(user.to_param)

      expect(body).to include "Next LeaderBit to receive: #{leaderbit3.name}"

      sleep 3
      within("#next_up_leaderbits") do
        page.accept_confirm do
          click_link "Delete"
        end
      end
      expect(page).to have_content("Instant Queue LeaderBit #{leaderbit3.name} has just been deleted")

      expect(body).to include "Next LeaderBit to receive: #{leaderbit1.name}"
    end
  end

  describe 'assign mentor manually' do
    let!(:user) { create(:user, organization: @user.organization) }
    let!(:user2) { create(:user, organization: @user.organization) }

    example do
      visit edit_admin_user_path(user.to_param)

      from = %(Add Mentor from "#{@user.organization.name}" Account:)
      select(user2.name, from: from)
      click_button 'Save'

      expect(page).to have_content "Mentor successfully assigned"
    end
  end

  describe 'remove mentor' do
    let!(:user) { create(:user, organization: @user.organization) }
    let!(:user2) { create(:user, organization: @user.organization) }

    example do
      create(:organizational_mentorship, mentor_user: user2, mentee_user: user)
      visit edit_admin_user_path(user.to_param)

      within('#mentors') do
        page.accept_confirm { click_link 'Delete' }
      end

      expect(page).to have_content "Mentor successfully detached."
    end
  end

  describe 'send lifetime progress report' do
    let(:user) { create(:user, organization: @user.organization) }
    let(:leaderbit) { create(:active_leaderbit) }
    let!(:completed_leaderbit_log) { create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::COMPLETED, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }
    let!(:entry_on_completed_leaderbit_log) { create(:entry, discarded_at: nil, leaderbit: leaderbit, user: user) }

    example do
      visit admin_user_path(user.to_param)
      page.accept_confirm do
        click_link 'Send Lifetime Progress Report'
      end
      expect(page).to have_content("Lifetime progress report has been sent")

      first_email_sent_to(user.email)
      expect(current_email.subject).to match(/you're progressing as a leader/)
    end
  end

  # Do we ever need it back?
  # describe '#toggle_discard' do
  #   context 'given active user' do
  #     let!(:user) { create(:user, organization: create(:organization, active_since: 3.days.ago)) }
  #
  #     it 'can be discarded' do
  #       visit admin_user_path(user)
  #       expect(page).to have_content(user.name)
  #
  #       page.accept_confirm do
  #         click_link 'Lock'
  #       end
  #       expect(page).to have_content("User successfully marked as destroyed")
  #     end
  #   end
  #
  #   context 'given discarded user' do
  #     let!(:user) { create(:user).tap(&:discard) }
  #
  #     it 'can be re-activated' do
  #       visit admin_user_path(user)
  #       expect(page).to have_content(user.name)
  #
  #       page.accept_confirm do
  #         click_link 'Unlock'
  #       end
  #       expect(page).to have_content("User successfully unlocked")
  #     end
  #   end
  # end

  describe 'destroy user' do
    let!(:user) { create(:user) }

    example do
      visit admin_user_path(user)
      expect(page).to have_content(user.name)

      page.accept_confirm do
        click_link 'Destroy'
      end
      expect(page).to have_content("User successfully destroyed")

      wait_for { current_path }.to eq(admin_users_path)

      expect(page).not_to have_content(user.name)
    end
  end

  describe 'reset password' do
    context 'given user who was created by admin(without password)' do
      let(:user) do
        user = User.new(email: Faker::Internet.email,
                        name: Faker::Name.name,
                        #technically these users don't need timezones at all
                        hour_of_day_to_send: 8,
                        day_of_week_to_send: 'Monday',
                        goes_through_leader_welcome_video_onboarding_step: true,
                        goes_through_leader_strength_finder_onboarding_step: true,
                        goes_through_team_survey_360_onboarding_step: true,
                        goes_through_organizational_mentorship_onboarding_step: true,
                        leaderbits_sending_enabled: true,
                        time_zone: ActiveSupport::TimeZone.all.sample.name,
                        schedule: create(:schedule),
                        created_by_user_id: User.first.id,
                        organization: create(:organization))

        def user.password_required?
          false
        end
        user.save!
        user
      end

      it 'allows admin to request password set/reset on user\s behalf' do
        visit admin_user_path(user.to_param)

        click_link 'URL for user to set a password'
        expect(page).to have_content('copy this')
        expect(page).to have_content('for user to set password')

        x = find("a", text: /this URL/)
        reset_password_url = x[:href]

        logout(:user)

        visit reset_password_url

        expect(page).to have_content('Set your password')
        new_password = 'abcdef'

        fill_in 'New password', with: new_password
        fill_in 'Confirm your new password', with: new_password

        click_button 'Set my password'

        expect(page).to have_content("Your password has been changed successfully")

        # sign in
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'abcdef'
        click_button 'Log in'

        # welcome page
        expect(page).to have_content("Your life")
        #expect(page).to have_content("Next Challenge Coming")
      end
    end
  end

  it 'can search users', skip: ENV['CI'].present? do
    organization = create(:organization)

    user1 = create(:user, email: 'jerbru@gmail.com', name: 'Jeremy Bruce', organization: organization)
    user2 = create(:user, email: 'john@brownfoundation.com', name: 'John Brown', organization: organization)

    visit admin_users_path
    expect(page).to have_content user1.name
    expect(page).to have_content user2.name

    fill_in 'query', with: 'Jeremy'
    click_button "Search"
    expect(page).to have_content user1.name
    expect(page).not_to have_content user2.name

    fill_in 'query', with: 'Jeremy bruce'
    click_button "Search"
    expect(page).to have_content user1.name
    expect(page).not_to have_content user2.name

    fill_in 'query', with: 'john@brownfoundation.com'
    click_button "Search"
    expect(page).not_to have_content user1.name
    expect(page).to have_content user2.name
  end
end
