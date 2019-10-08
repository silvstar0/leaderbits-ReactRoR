# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Entries', type: :feature, js: true do
  context 'signed in as regular user' do
    let(:leaderbit) { create(:leaderbit) }

    before do
      @user = create(:user,
                     goes_through_leader_welcome_video_onboarding_step: false,
                     goes_through_leader_strength_finder_onboarding_step: false,
                     goes_through_team_survey_360_onboarding_step: false,
                     goes_through_organizational_mentorship_onboarding_step: false)
      login_as(@user, scope: :user, run_callbacks: false)

      create(:user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit)
    end

    describe 'Entry show page' do
      before do
        user = create(:system_admin_user)
        login_as(user, scope: :user, run_callbacks: false)
      end

      it 'allows system admin to update user notes' do
        user = create(:user, admin_notes: nil)
        entry = create(:entry, user: user, discarded_at: nil)

        visit entry_group_path(entry.entry_group.to_param)
        expect(body).not_to have_content('My Notes')

        page.evaluate_script %(document.querySelector('.fa-lightbulb-o').click())

        within('[action="/admin/user-notes"]') do
          fill_in('content', with: 'My Notes')
        end
        sleep 2 # text_area is saved every second

        visit entry_group_path(entry.entry_group.to_param)
        expect(body).to have_content('My Notes')
      end
    end

    it 'can create entry', skip: ENV['CI'].present? do
      visit leaderbit_path(leaderbit.to_param)
      expect(page).to have_content leaderbit.name

      fill_in('entry_content', with: "That is awesome")
      click_button('Create Entry')

      sleep 1 # it keeps failing on CI and keeps failing locally. Try increasing sleep time
      expect(page).to have_content 'Achievement Unlocked'
      expect(page).to have_content 'Congratulations'
      expect(page).to have_content 'You\'ve unlocked your dashboard.'

      visit current_path # reload

      # can see posted entry
      expect(page).to have_content 'That is awesome'

      # now go to dashboard and check another modal success message:
      visit dashboard_path

      expect(page).to have_content 'Success'
      expect(page).to have_content "You've completed your first challenge"
    end

    it 'update its own entry' do
      entry = create(:entry, discarded_at: nil, content: 'Hello World', leaderbit: leaderbit, user: @user)
      visit leaderbit_path(leaderbit.to_param)

      expect(page).to have_content leaderbit.name
      expect(page).to have_content entry.content

      click_link('Edit')
      sleep 1
      within('.replaceable') do
        fill_in('entry_content', with: "Rails6")
      end
      #sleep 1
      click_button('Update Entry')

      expect(page).not_to have_content('Hello World')
      expect(page).to have_content('Rails6')

      visit current_path # reload
      expect(page).to have_content('Rails6')
    end
  end

  context 'signed in as system admin' do
    before do
      user = create(:system_admin_user,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can mark entry as read manually' do
      entry = create(:entry, discarded_at: nil)

      #visit unread_entry_groups_path
      visit entry_groups_path hide_read: 'true'
      expect(page).to have_content entry.content

      page.accept_confirm do
        click_link('Mark Entry as Read')
      end

      sleep 1 # sleep added on feb 2019 lets see if it reliably fixes unstable test

      #reload
      visit entry_groups_path hide_read: 'true'

      #TODO why it randomly fails here? Feb 2019
      expect(page).not_to have_content entry.content

      # still on "All Entries" list:
      visit entry_groups_path
      expect(page).to have_content entry.content
    end

    it 'can like entry' do
      entry = create(:entry, discarded_at: nil)

      #visit unread_entry_groups_path
      visit entry_groups_path
      expect(page).to have_content entry.content

      #sleep 1 # js

      #TODO check that NOT liked before update
      # expect(page).not_to have_content('Liked')

      press 'Like'
      sleep 1

      #visit current_path # reload # show page
      visit entry_groups_path
      #sleep 1

      style = page.evaluate_script("$('a:contains(Like)').attr('style')")
      expect(style).to include('bold')
    end

    it 'can reply to an entry' do
      entry = create(:entry, discarded_at: nil)

      #visit unread_entry_groups_path
      visit entry_groups_path hide_read: 'true'
      expect(page).to have_content entry.content

      press 'Reply'

      #sleep 1

      fill_in with: 'My Message', class: 'reply_content'

      press 'Send Reply'

      sleep 1
      #visit current_path # reload # show page
      visit entry_groups_path hide_read: 'true'
      #sleep 1
      expect(page).not_to have_content 'My Message'

      visit entry_groups_path
      sleep 1
      expect(page).to have_content 'My Message'
    end
  end

  context 'signed in as team leader' do
    before do
      user = create(:team_leader_user,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can reply to an entry' do
      user2 = create(:user).tap { |u| TeamMember.create! role: TeamMember::Roles::MEMBER, user: u, team: Team.first! }
      entry = create(:entry, discarded_at: nil, visible_to_my_peers: true, user: user2)

      #visit unread_entry_groups_path
      visit entry_groups_path hide_read: 'true'
      expect(page).to have_content entry.content

      press 'Reply'

      #sleep 1

      fill_in with: 'My Message', class: 'reply_content'

      press 'Send Reply'

      sleep 1
      visit entry_groups_path hide_read: 'true'
      #sleep 1
      expect(page).not_to have_content 'My Message'

      visit entry_groups_path
      #sleep 1
      expect(page).to have_content 'My Message'
    end
  end

  context 'signed in as employee' do
    before do
      login_as(current_user, scope: :user, run_callbacks: false)
    end

    let!(:current_user) do
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: false,
             goes_through_leader_strength_finder_onboarding_step: false,
             goes_through_team_survey_360_onboarding_step: false,
             goes_through_organizational_mentorship_onboarding_step: false).tap { |u| LeaderbitsEmployee.create! user: u, organization: organization }
    end

    let(:organization) { create(:organization) }
    let!(:entry) do
      user = create(:user, organization: organization)
      create(:entry, discarded_at: nil, user: user)
    end
    let!(:leaderbit_employee_mentorship) { LeaderbitEmployeeMentorship.create! mentor_user: current_user, mentee_user: entry.user }

    it 'can like entry' do
      visit entry_groups_path
      expect(page).to have_content entry.content

      #TODO check that NOT liked before update
      # expect(page).not_to have_content('Liked')

      press 'Like'
      sleep 1

      visit current_path # reload # show page
      #sleep 1

      style = page.evaluate_script("$('a:contains(Like)').attr('style')")
      expect(style).to include('bold')
    end

    it 'can reply to an entry' do
      visit entry_groups_path
      expect(page).to have_content entry.content

      press 'Reply'

      #sleep 1

      fill_in with: 'My Message', class: 'reply_content'

      press 'Send Reply'
      sleep 1

      visit current_path # reload # show page

      expect(page).to have_content 'My Message'
    end
  end
end
