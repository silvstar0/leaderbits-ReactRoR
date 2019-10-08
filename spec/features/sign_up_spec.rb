# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign Up', type: :feature, js: true do
  before do
    Schedule.create! name: Schedule::GLOBAL_NAME
    visit root_path

    click_link "Don't have an account yet? Get started here."
  end

  it 'can sign up as new acccount and new user', skip: 'Sign Ups are not yet publicly enabled so ignore' do
    fill_in 'Company', with: 'Microsoft'
    fill_in 'Name', with: 'David Heinemeier Hansson'

    fill_in 'Email', with: 'dhh@leaderbits.io'
    fill_in 'Password', with: 'jonesdmm'

    click_button "I'm ready, let's do this!"

    expect_to_see_welcome_page
    expect(page).to have_content("David,")
  end

  it 'can sign up as new account and new user', skip: 'Sign Ups are not yet publicly enabled so ignore' do
    create(:organization, active_since: 3.weeks.ago, name: "Microsoft")
    fill_in 'Company', with: 'Microsoft'
    fill_in 'Name', with: 'David Heinemeier Hansson'

    fill_in 'Email', with: 'dhh@leaderbits.io'
    fill_in 'Password', with: 'jonesdmm'

    click_button "I'm ready, let's do this!"

    expect_to_see_welcome_page
    expect(page).to have_content("David,")

    #still
    expect(Organization.count).to eq(1)
  end
end
