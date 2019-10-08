# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Schedules", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can create new schedule' do
      visit admin_schedules_path

      click_link 'New Schedule'

      fill_in('Name', with: 'FooBar Plan')
      click_button('Create Schedule')

      sleep 1
      expect(page).to have_content 'Schedule successfully created'
      expect(body).to include('FooBar Plan')

      visit current_path # reload # show page

      expect(body).to include('FooBar Plan')
    end

    it 'can add leaderbit to schedule' do
      schedule = create(:schedule)
      leaderbit = create(:active_leaderbit)

      visit admin_schedule_path(schedule)
      expect(page).to have_content schedule.name

      expect(page).not_to have_link(leaderbit.name)
      expect(page).to have_content("Add LeaderBit To Schedule")

      sleep 1
      page.evaluate_script("$('select#leaderbit_id').val(#{leaderbit.id}).change()")

      # wait for ajax to complete
      sleep 1

      visit current_path # reload # show page
      expect(page).to have_link(leaderbit.name)
    end

    it 'can delete leaderbit from schedule' do
      schedule = create(:schedule)
      leaderbit = create(:active_leaderbit)

      schedule.leaderbit_schedules.create! leaderbit: leaderbit

      visit admin_schedule_path(schedule)
      expect(page).to have_content schedule.name

      expect(page).to have_link(leaderbit.name)

      page.accept_confirm do
        click_link 'Delete'
      end

      # wait for ajax to complete
      sleep 1

      visit current_path # reload # show page
      expect(page).not_to have_link(leaderbit.name)
    end

    it 'can destroy schedule ' do
      schedule = create(:schedule)
      visit admin_schedules_path
      expect(page).to have_content(schedule.name)

      page.accept_confirm do
        click_link 'Destroy'
      end

      expect(page).to have_content('Schedule successfully destroyed')
      expect(page).not_to have_content(schedule.name)
    end
  end
end
