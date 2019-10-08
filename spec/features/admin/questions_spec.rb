# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Questions", type: :feature, js: true do
  context 'given system admin user' do
    before do
      user = create(:system_admin_user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'can create new survey question', skip: ENV['CI'].present? do
      survey = create(:survey, type: Survey::Types::FOR_LEADER)
      visit admin_survey_path(survey)

      click_link 'New Question'

      sleep 1
      #TODO extract it as you may need it in other react components

      #why it is failing randomly on CI?
      # Selenium::WebDriver::Error::UnknownError:
      #   unknown error: Cannot set property 'value' of null
      # (Session info: headless chrome=71.0.3578.98)
      # (Driver info: chromedriver=2.45.615279 (12b89733300bd268cff3b78fc76cb8f3a7cc44e5),platform=Linux 4.4.0-141-generic x86_64)
      # ./spec/features/admin/questions_spec.rb:20:in `block (3 levels) in <top (required)>'
      #page.evaluate_script %( document.getElementById('question_input').value = "FooBar" )
      #page.evaluate_script " TestUtils.Simulate.change( document.getElementById('question_input') )"
      fill_in('question_input', with: 'FooBar')
      click_button "Create Question"

      expect(page).to have_content 'Question successfully created'
      expect(body).to include('FooBar')

      visit current_path # reload # show page

      expect(body).to include('FooBar')
    end

    it 'can update survey question', skip: ENV['CI'].present? do
      question = create(:single_textbox_question)

      visit admin_survey_path(question.survey)
      expect(page).not_to have_content('Updated Title')

      visit edit_admin_survey_question_path(question.survey, question)

      fill_in('question_input', with: 'Updated Title')
      click_button('Update Question')
      #TODO add sleep? sometimes it fails
      #sleep 1

      visit admin_survey_path(question.survey)
      expect(page).to have_content('Updated Title')
    end

    it 'can destroy question' do
      question = create(:single_textbox_question)
      survey = question.survey

      visit admin_survey_path(survey)
      expect(page).to have_content(question.title)

      page.accept_confirm do
        click_link("Delete")
      end

      wait_for { current_path }.to eq(admin_survey_path(survey))
      expect(page).to have_content("Question successfully destroyed")
      expect(page).not_to have_content(question.title)
    end
  end
end
