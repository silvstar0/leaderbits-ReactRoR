# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'simple_auth_token_authentication for old links middleware', type: :feature, js: true do
  let(:leaderbit) { create(:active_leaderbit) }
  let(:schedule) { Schedule.create!(name: Schedule::GLOBAL_NAME).tap { |schedule| schedule.leaderbit_schedules.create! leaderbit: leaderbit } }
  let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

  context 'given old expired auth link' do
    let(:user) { create(:user, email: 'john.brown@gmail.com', schedule: schedule) }

    example do
      old_authentication_token = user.issue_new_authentication_token_and_return
      EmailAuthenticationToken.where(authentication_token: old_authentication_token).first!.update_column(:valid_until, 1.year.ago)
      user.issue_new_authentication_token_and_return

      visit start_leaderbit_path(leaderbit.to_param, user_email: user.email, user_token: old_authentication_token )
      magic_link_could_be_resent
    end
  end

  def magic_link_could_be_resent
    expect(page).to have_content('Auth link expired')
    click_button 'Send Magic Link'

    expect(page).to have_content('Check your email')
    expect(page).to have_content("We've sent an email to j********n@gmail.com")
  end
end
