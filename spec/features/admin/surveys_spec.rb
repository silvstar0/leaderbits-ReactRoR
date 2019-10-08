# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Surveys", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)

      create(:survey, type: Survey::Types::FOR_LEADER)
    end

    it 'can update existing survey' do
      visit admin_surveys_path

      click_link 'Edit' # survey.title

      fill_in('Title', with: 'FooBar')
      click_button('Update Survey')

      expect(page).to have_content 'Survey successfully updated'
      expect(body).to include('FooBar')

      visit current_path # reload # show page

      expect(body).to include('FooBar')
    end
  end
end
