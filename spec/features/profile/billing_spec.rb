# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Billing', type: :feature, js: true do
  def add_credit_card
    expect(page).not_to have_content 'Your Card'
    expect(page).to have_content 'Add Credit Card'

    click_button 'Add Credit Card'

    sleep 2 # do not remove, frame loading

    #NOTE: in case you may need some Stripe capybara testing inspiration:
    # https://github.com/dblock/slack-gamebot/blob/master/spec/integration/update_cc_spec.rb
    stripe_iframe = all('iframe[name=stripe_checkout_app]').last
    Capybara.within_frame stripe_iframe do
      #NOTE: you need really unique email here.
      # Otherwise Stripe UI just skips filling the rest of the form and proceeds to verification confirmation instead
      email = "#{SecureRandom.base64.tr('+/=', 'Qrt').downcase}@leaderbits.io"
      page.find_field('Email').set email
      page.find_field('Card number').set '4242 4242 4242 4242'
      page.find_field('MM / YY').set '12/19'
      page.find_field('CVC').set '123'

      find('button[type="submit"]').click
    end
    sleep 5 # do not remove. Giving it some time to perform request to Stripe and back to us

    visit profile_billing_path

    expect(page).to have_content 'Update Credit Card'
    #sleep 5
    expect(page).to have_content 'Visa'
    expect(page).to have_content '**** **** **** 4242'
  end

  def update_credit_card
    #expect(page).not_to have_content 'Your Card'
    #expect(page).to have_content 'Add Credit Card'

    click_button 'Update Credit Card'

    sleep 2 # do not remove, frame loading

    #NOTE: in case you may need some Stripe capybara testing inspiration:
    # https://github.com/dblock/slack-gamebot/blob/master/spec/integration/update_cc_spec.rb
    stripe_iframe = all('iframe[name=stripe_checkout_app]').last
    Capybara.within_frame stripe_iframe do
      #NOTE: you need really unique email here.
      # Otherwise Stripe UI just skips filling the rest of the form and proceeds to verification confirmation instead
      email = "#{SecureRandom.base64.tr('+/=', 'Qrt').downcase}@leaderbits.io"
      page.find_field('Email').set email
      page.find_field('Card number').set '5555 5555 5555 4444'
      page.find_field('MM / YY').set '11/20'
      page.find_field('CVC').set '345'

      find('button[type="submit"]').click
    end
    sleep 5 # do not remove. Giving it some time to perform request to Stripe and back to us

    visit profile_billing_path

    expect(page).to have_content 'Update Credit Card'
    expect(page).to have_content 'Mastercard'
    expect(page).to have_content '**** **** **** 4444'
  end

  it 'can add and update credit card' do
    user = create(:c_level_user,
                  goes_through_leader_welcome_video_onboarding_step: false,
                  goes_through_leader_strength_finder_onboarding_step: false,
                  goes_through_team_survey_360_onboarding_step: false,
                  goes_through_organizational_mentorship_onboarding_step: false)
    login_as(user, scope: :user, run_callbacks: false)

    visit root_path

    mouseover_top_menu_item user.first_name

    click_link 'Billing'

    add_credit_card

    update_credit_card
  end
end
