# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Teams", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'displays list of existing teams' do
      team = create(:team)
      visit admin_teams_path

      expect(page).to have_content(team.name)
      expect(page).to have_content(team.organization.name)
    end

    it 'can see individual team' do
      team = create(:team)
      user = create(:user, organization: team.organization)
      TeamMember.create! user: user, role: TeamMember::Roles::MEMBER, team: team

      visit admin_teams_path

      click_link 'View'

      expect(page).to have_content(team.name)
      expect(page).to have_content(user.name)
      expect(page).to have_content('Member')
    end
  end
end
