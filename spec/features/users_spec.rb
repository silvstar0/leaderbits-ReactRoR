# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Users", type: :feature, js: true do
  let(:organization) { create(:organization) }

  #TODO do we still need it?
  describe 'add leaderbit to Instant Queue queue' do
    before do
      @user = create(:c_level_user, organization: organization, leaderbits_sending_enabled: false)
      login_as(@user, scope: :user, run_callbacks: false)
    end

    let(:user) { create(:user, organization: @user.organization) }
    let(:leaderbit1) { create(:active_leaderbit) }
    let(:leaderbit2) { create(:active_leaderbit) }
    let(:leaderbit3) { create(:active_leaderbit) }

    example do
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit2
      user.schedule.leaderbit_schedules.create! leaderbit: leaderbit3

      visit user_path(user.to_param)

      press 'Add Challenge to Instant Queue'
      find("##{Rails.configuration.add_to_next_up_select_dom_id}").select(leaderbit3.name)

      click_button("Add to Instant Queue")
      expect(page).to have_content "#{leaderbit3.name} has just been added to the Instant Queue for #{user.name}"
    end
  end
end
