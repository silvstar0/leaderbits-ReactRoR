# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', type: :feature, js: true do
  context 'Given signed in regular user, from dashboard' do
    let(:leaderbit) { create(:leaderbit) }
    let(:leaderbit2) { create(:leaderbit) }

    before do
      user = create(:user,
                    leaderbits_sending_enabled: true,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false)
      login_as(user, scope: :user, run_callbacks: false)

      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
    end

    it 'can access list of sent leaderbits' do
      visit root_path

      sleep 3
      expect(page).to have_content 'All challenges'
      visit leaderbits_path

      expect(page).to have_content leaderbit.name
      expect(page).not_to have_content leaderbit2.name
    end
  end
end
