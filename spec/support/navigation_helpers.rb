# frozen_string_literal: true

module NavigationHelpers
  def expect_leaderbit_start_message
    sleep 1
    #sleep 2 # still failing sometimes with 1
    expect(page).to have_content 'You earned'
    expect(page).to have_content 'points for starting this LeaderBit'
  end

  def mouseover_top_menu_item(name)
    page.evaluate_script("$('a:contains(#{name})').mouseover()")
  end

  def open_your_profile
    raise "@user must be before ##{__method__}" if @user.nil?

    visit root_path

    mouseover_top_menu_item @user.first_name

    click_link 'Your Profile'
  end

  #TODO this helper method could include more than just checking
  # so that we can DRY some specs
  def expect_being_logged_in(as_user)
    expect(page).to have_content as_user.first_name
    # Dashboard & My Points presence is not a reliable indicator - because leaderbits_sending_enabled=false don't have those but still might be logged in
    #expect(page).to have_content 'Dashboard'
    #expect(page).to have_content 'My Points'
  end

  def expect_to_see_welcome_page
    expect(page).to have_content("Your life is about to get a lot more interesting.")
    expect(page).to have_content("Watch the 3 minute video below to begin")
  end

  def expect_account_is_locked_while_logging_in(email:, password:)
    visit root_path

    fill_in 'Email', with: email
    fill_in 'Password', with: password

    click_button 'Log in'

    expect(page).to have_content "Your account is currently locked"
  end

  def sign_out_as(_user)
    visit destroy_user_session_path
    #mouseover_top_menu_item user.first_name
    #click_link 'Logout'
  end

  # this non-capybara term/method abstract the underlying complexity
  def press(title)
    # anonymous function because capybara doesn't like multiline scripts
    # "custom" event triggering because it is React component and jQuery's click triggers its own event instead
    page.evaluate_script <<~CODE
      function() {
        var event = document.createEvent("HTMLEvents");
        event.initEvent("click", true, true);
        var target = $('button:contains(#{title}),a:contains(#{title}),input[value="#{title}"]')[0];
        target.dispatchEvent(event);
      }()
    CODE
  end
end

RSpec.configure do |c|
  c.include NavigationHelpers, type: :feature
end
