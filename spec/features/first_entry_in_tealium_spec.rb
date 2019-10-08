# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'New(first) entry in Tealium', type: :feature, js: true do
  #TODO: this story is not specifically about Tealium, it's general use case of
  # notifying inactive mentors
  let(:organization) { create(:organization, name: 'Tealium') }

  let!(:team) { create(:team, organization: organization) }

  let!(:team_leader) do
    #Allison: "Jeff is the mentor/owner of a team only, he will not be receiving challenges"
    create(:user,
           name: 'Jeff Lansford',
           goes_through_leader_strength_finder_onboarding_step: false,
           goes_through_team_survey_360_onboarding_step: false,
           goes_through_organizational_mentorship_onboarding_step: false,
           organization: organization,
           leaderbits_sending_enabled: false).tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::LEADER, team: team }
  end

  let!(:team_member) do
    create(:user,
           name: 'Laurie Schrager',
           organization: organization,
           goes_through_leader_welcome_video_onboarding_step: true,
           goes_through_leader_strength_finder_onboarding_step: true,
           goes_through_team_survey_360_onboarding_step: true,
           goes_through_organizational_mentorship_onboarding_step: false,
           leaderbits_sending_enabled: true).tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: team }
  end

  context 'given 1st entry for team leader' do
    it 'sends notification with magic auto sign in link to mentor' do
      #TODO High do you really need to check visible_to_my_peers status?
      entry = create(:entry, discarded_at: nil, user: team_member, visible_to_my_peers: true)

      first_email_sent_to(team_leader.email)

      expect(current_email.subject).to eq("New entry for you to review")
      current_email.click_link('Click here')

      expect(page).to have_content(entry.content)

      #those users don't need that functionality
      expect(page).not_to have_content('Dashboard')
      expect(page).not_to have_content('My Points')

      # important here is that user is not forced to watch welcome video instead
      visit entry_groups_path

      expect(page).to have_content(entry.content)
      expect(page).to have_content('Total Entries')
    end
  end
end

#We’ve started to customize your leadership program.
