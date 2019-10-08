# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SwitchUser visibility', type: :feature, js: true do
  context 'given system admin' do
    before do
      @user = create(:system_admin_user,
                     goes_through_leader_welcome_video_onboarding_step: false,
                     goes_through_leader_strength_finder_onboarding_step: false,
                     goes_through_team_survey_360_onboarding_step: false,
                     goes_through_organizational_mentorship_onboarding_step: false,
                     name: "John Brown")
      login_as(@user, scope: :user, run_callbacks: false)
    end

    it 'can switch to another user' do
      user = create(:user,
                    goes_through_leader_welcome_video_onboarding_step: false,
                    goes_through_leader_strength_finder_onboarding_step: false,
                    goes_through_team_survey_360_onboarding_step: false,
                    goes_through_organizational_mentorship_onboarding_step: false,
                    name: 'Mike Pence')
      visit admin_users_path
      expect(page).to have_content(user.first_name)
      click_link "Sign In"

      expect(page).not_to have_content(@user.first_name)
      wait_for { current_path }.to eq(dashboard_path)
    end

    #NOTE: do not verify other use cases because those are handled on controller level
  end
end
