# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizational Mentorship', type: :feature, js: true do
  let!(:schedule) { Schedule.create! name: Schedule::GLOBAL_NAME }
  let!(:leaderbit_schedule) { schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit) }

  before do
    @user = create(:user,
                   can_create_a_mentee: true,
                   schedule: schedule,
                   goes_through_leader_welcome_video_onboarding_step: false,
                   goes_through_leader_strength_finder_onboarding_step: false,
                   goes_through_team_survey_360_onboarding_step: false,
                   goes_through_organizational_mentorship_onboarding_step: false)
    login_as(@user, scope: :user, run_callbacks: false)

    visit root_path
    mouseover_top_menu_item @user.first_name

    click_link 'Mentorship'
  end

  describe 'full cycle of adding and accepting invitation' do
    it 'can enter mentee and mentee can accept invitation' do
      email = 'user@foo.com'

      can_enter_mentee name: 'John Brown', email: email

      first_email_sent_to(email)
      expect(current_email.subject).to eq("Mentor invitation from #{@user.name}")

      logout(:user)
      current_email.click_link('accept the invitation here')

      expect(page).to have_content("Invitation has been accepted")
      expect(page).to have_content("You will receive an email with your first LeaderBit shortly.")

      expect(all_emails[1].subject).to eq('John Brown has accepted your invitation')
    end
  end

  #TODO-low restore this spec. It worked at some point(we used React component back then but it was replaced with inline js some time ago)
  # pending 'can add new mentee from organization users list by click on name' do
  #   # expect(body).not_to include("John Brown")
  #   # user = create(:user, name: 'John Brown')
  #   # press user.name
  #   # click_button('Save')
  #   #
  #   # expect(body).to include("John Brown")
  # end

  def can_enter_mentee(name:, email:)
    click_link 'Add New Mentee'

    expect(body).not_to include(email)

    fill_in 'Email', with: email
    fill_in 'Name', with: name
    click_button('Save')

    visit current_path # reload

    expect(body).to include(email)
  end
end
