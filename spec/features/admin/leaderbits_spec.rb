# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Leaderbits", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can create new leaderbit' do
      visit admin_leaderbits_path

      expect(page).to have_link('New LeaderBit')
      click_link 'New LeaderBit'

      fill_in('Name', with: 'Foo')
      fill_in('Desc', with: 'Bar')
      fill_in('URL', with: 'https://player.vimeo.com/video/273215632')

      attach_file("Video cover", Rails.root.join("app/assets/images/video_covers/default.png"))
      fill_in_trix_editor('leaderbit_body', with: 'Quux')

      click_button('Create Leaderbit')

      sleep 1
      expect(page).to have_content 'LeaderBit successfully created'
      expect(body).to include('Foo')

      visit current_path # reload # show page

      expect(body).to include('Foo')
    end

    it 'can update leaderbit' do
      leaderbit = create(:leaderbit)

      visit admin_leaderbit_path(leaderbit)
      click_link 'Edit'

      fill_in('Name', with: 'New Leaderbit Name')
      click_button('Update Leaderbit')

      sleep 1
      expect(page).to have_content 'LeaderBit successfully updated'

      visit admin_leaderbit_path(leaderbit)
      expect(body).to include('New Leaderbit Name')
    end

    it 'can search leaderbits' do
      leaderbit1 = create(:active_leaderbit, name: 'Autonomous Leadership')
      leaderbit2 = create(:active_leaderbit, name: 'Leaders curate their environment')
      leaderbit3 = create(:active_leaderbit, name: 'Staying Sharp by Learning Through Osmosis')

      visit admin_leaderbits_path

      expect(page).to have_content leaderbit1.name
      expect(page).to have_content leaderbit2.name
      expect(page).to have_content leaderbit3.name

      fill_in 'query', with: 'autonomous'
      click_button "Search"

      expect(page).to have_content leaderbit1.name
      expect(page).not_to have_content leaderbit2.name
      expect(page).not_to have_content leaderbit3.name
    end
  end

  context 'given employee user' do
    before do
      user = create(:employee_user,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can see list of leaderbits and can create new one' do
      visit admin_leaderbits_path

      expect(body).to include('LeaderBits')
      expect(page).to have_link('New LeaderBit')
    end
  end
end
