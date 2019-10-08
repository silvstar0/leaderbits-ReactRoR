# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Organizations", type: :feature, js: true do
  context 'given system admin user' do
    before do
      @user = create(:system_admin_user)
      login_as(@user, scope: :user, run_callbacks: false)
    end

    it 'can create new organization' do
      visit admin_organizations_path

      click_link 'New Account'

      fill_in('Name', with: 'FooBar')
      click_button('Create Organization')

      sleep 1
      expect(page).to have_content 'Organization successfully created'
      expect(body).to include('FooBar')

      visit current_path # reload # show page

      expect(body).to include('FooBar')
    end

    it 'can update organization' do
      organization = create(:organization)
      visit admin_organization_path(organization)

      click_link 'Edit'

      fill_in('Name', with: 'Updated Name')
      click_button('Update Organization')

      expect(page).to have_content 'Account successfully updated'
      expect(body).not_to include(organization.name)
      expect(body).to include('Updated Name')

      visit current_path # reload # show page

      expect(body).to include('Updated Name')
    end

    it 'can can search by name' do
      organization1 = create(:organization, name: 'Foo')
      organization2 = create(:organization, name: 'Bar')

      visit admin_organizations_path

      expect(page).to have_content organization1.name

      fill_in 'query', with: 'foo'
      click_button "Search"

      expect(page).to have_content organization1.name
      expect(page).not_to have_content organization2.name
    end

    describe 'send lifetime progress report' do
      let(:user) { create(:user, organization: @user.organization) }
      let(:leaderbit) { create(:active_leaderbit) }
      let!(:completed_leaderbit_log) { create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::COMPLETED, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }
      let!(:entry_on_completed_leaderbit_log) { create(:entry, leaderbit: leaderbit, user: user) }

      example do
        visit admin_organization_path(@user.organization.to_param)

        #open modal
        page.evaluate_script "$('a:contains(Send Lifetime Progress Report)').click()"

        fill_in 'recipient_email', with: 'user1@gmail.com'
        click_button 'Send Report'
        expect(page).to have_content("Lifetime progress report has been sent")

        first_email_sent_to('user1@gmail.com')
        expect(current_email.subject).to match(/Progress Report/)
      end
    end
  end
end
