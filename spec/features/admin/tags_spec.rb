# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Tags", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'displays list of existing tags' do
      visit admin_dashboard_path

      question_tag = create(:question_tag)
      leaderbit_tag = create(:leaderbit_tag)

      click_link 'Tags'
      expect(page).to have_content(question_tag.label)
      expect(page).to have_content(leaderbit_tag.label)
    end

    it 'can view existing tag' do
      tag = if [true, false].sample
              create(:question_tag)
            else

              create(:leaderbit_tag)
            end
      visit admin_tags_path

      click_link 'View'
      expect(page).to have_content(tag.label)
    end

    it 'can update existing tag' do
      tag = if [true, false].sample
              create(:question_tag)
            else

              create(:leaderbit_tag)
            end

      visit admin_tags_path

      click_link 'Edit'
      fill_in('Label', with: "Updated Tag Name")
      click_button("Rename Tag")

      expect(page).to have_content("successfully renamed")

      visit admin_tags_path
      expect(page).not_to have_content(tag.label)
      expect(page).to have_content("Updated Tag Name")
    end
  end
end
