# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Companies", type: :feature, js: true do
  context 'given c-level user' do
    before do
      @user = create(:c_level_user, leaderbits_sending_enabled: false)
      login_as(@user, scope: :user, run_callbacks: false)
    end

    it 'can create new team' do
      visit root_path
      click_link 'Company'
      click_link 'Add New Team'

      # teams#new page
      expect(page).not_to have_content 'Add New Team'

      fill_in('Name', with: 'FooBar')
      click_button('Save')

      # teams#index page
      expect(page).to have_content 'Add New Team'
      expect(page).to have_content 'FooBar'
    end

    it 'can update his team' do
      team = create(:team, organization: @user.organization)

      visit root_path
      click_link "Company"

      expect(page).to have_content(team.name)
      click_link team.name
      fill_in('Name', with: 'Dream Team')
      click_button('Save')

      expect(page).to have_content('Team successfully updated')
    end
  end

  context 'given team leader user' do
    let(:organization) { create(:organization) }

    before do
      @user = create(:team_leader_user, organization: organization, leaderbits_sending_enabled: false)
      login_as(@user, scope: :user, run_callbacks: false)

      @team = Team.first!

      @team_member_user = create(:user, organization: organization)
      TeamMember.create! user: @team_member_user, team: @team, role: TeamMember::Roles::MEMBER
    end

    it 'can see team and its members' do
      visit root_path

      click_link 'Company'

      #click_link @team.name

      #wait_for { current_path }.to eq(team_users_path(@team))
      expect(page).to have_content(@team.name)

      expect(page).to have_content(@team_member_user.name)
    end
  end
end
