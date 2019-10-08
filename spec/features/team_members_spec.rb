# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Team members", type: :feature, js: true do
  let(:organization) { create(:organization) }

  # that's precondition for displaying *Add New Person* links
  let!(:possible_user_to_be_added_as_team_member) { create(:user, name: 'John Brown', organization: organization, leaderbits_sending_enabled: true) }

  context 'given team leader user' do
    before do
      @user = create(:team_leader_user,
                     goes_through_leader_welcome_video_onboarding_step: false,
                     goes_through_leader_strength_finder_onboarding_step: false,
                     goes_through_team_survey_360_onboarding_step: false,
                     goes_through_organizational_mentorship_onboarding_step: false,
                     organization: organization)
      login_as(@user, scope: :user, run_callbacks: false)
    end

    #TODO-High add spec where you select one of the

    it 'can create new team member' do
      Schedule.create! name: Schedule::GLOBAL_NAME
      create(:team, organization: organization)

      visit root_path
      click_link 'Company'
      click_link 'Add New Person'

      # team_members#new page
      expect(page).not_to have_content 'Add New Person'

      #fill_in('Name', with: 'John')
      #fill_in('Email', with: 'foobar@gmail.com')
      choose('John Brown')

      click_button('Save')

      expect(page).to have_content 'has been added'
      expect(body).to include('John')

      # TODO check role
    end

    it 'can destroy(discard) user' do
      @team = Team.first!

      @team_member_user = create(:user, organization: organization)
      TeamMember.create! user: @team_member_user, team: @team, role: TeamMember::Roles::MEMBER

      #visit organization_users_path(organization)
      visit root_path
      click_link 'Company'

      name = @team_member_user.name
      click_link name

      expect(page).to have_content(name)

      page.accept_confirm do
        click_link("#{name} is no longer part of the team")
      end

      expect(page).to have_content('is no longer part of the team')

      visit company_path
      expect(page).not_to have_content(@team_member_user.name)
    end
  end
end
