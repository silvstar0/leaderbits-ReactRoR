# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accountability', type: :feature, js: true do
  before do
    @user = create(:user, notify_observer_if_im_trying_to_hide: false, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false)
    login_as(@user, scope: :user, run_callbacks: false)

    visit root_path

    mouseover_top_menu_item @user.first_name
  end

  it 'can add new recipient' do
    click_link 'Accountability'
    wait_for { current_path }.to eq(profile_accountability_path)

    expect(page).not_to have_content('newuser@domain.com')
    click_link 'Add New Person'

    within('.new_progress_report_recipient') do
      #within("#progress-reports-recipients") do
      fill_in 'Email', with: 'newuser@domain.com'
      fill_in 'Name', with: 'John Brown'
      select 'Monthly', from: 'Frequency'

      click_button('Save')
    end
    expect(page).to have_content('has been added')
    expect(body).to include('newuser@domain.com')

    # it is important to create new progress report recipients with blank schedule -
    # otherwise we won't be able to distinguish there "technical" users from "real" users
    expect(User.find_by_email('newuser@domain.com').schedule).to be_blank
  end

  context 'given some users as progress report recipients' do
    let(:user) { create(:user, email: 'foo@gmail.com', organization: @user.organization) }

    let!(:progress_report_recipient) { create(:progress_report_recipient, user: user, added_by_user: @user) }

    it "can change *Slacking off selector*" do
      click_link 'Accountability'
      wait_for { current_path }.to eq(profile_accountability_path)

      enable_slacking_of_notification_for_user(user)

      visit current_path # reload
      within("#slacking-off") do
        expect(find('#user_progress_report_recipient_id').value).to eq(progress_report_recipient.id.to_s)
      end
    end

    it "remove progress report participant" do
      click_link 'Accountability'
      wait_for { current_path }.to eq(profile_accountability_path)

      can_remove_progress_report_participant user.name

      # user must not be notified
      first_email_sent_to('foo@gmail.com')
      expect(current_email).to be_blank
    end
  end

  it "can toggle *Don't quit, keep going.*" do
    click_link 'Accountability'
    wait_for { current_path }.to eq(profile_accountability_path)

    within("#dont-quit-keep-going") do
      expect(find('#user_notify_me_if_i_missing_2_weeks_in_a_row').value).to eq("true")

      find('#user_notify_me_if_i_missing_2_weeks_in_a_row').select('Disabled')
      click_button('Save')
    end
    visit current_path # reload
    within("#dont-quit-keep-going") do
      expect(find('#user_notify_me_if_i_missing_2_weeks_in_a_row').value).to eq("false")
    end
  end

  describe 'trying to hide' do
    context 'given Enabled *Trying to hide*' do
      let(:user) { create(:user, email: 'foo@gmail.com', organization: @user.organization) }
      let!(:progress_report_recipient) { create(:progress_report_recipient, user: user, added_by_user: @user) }

      it "notifies user if I remove him from the list of progress report recipients" do
        click_link 'Accountability'
        wait_for { current_path }.to eq(profile_accountability_path)

        enable_trying_to_hide

        can_remove_progress_report_participant user.name

        first_email_sent_to(user.email)
        expect(current_email.subject).to eq("#{progress_report_recipient.added_by_user.first_name} is trying to hide")
      end

      it "notifies progress report recipients if I turn off *Trying to hide*" do
        click_link 'Accountability'
        wait_for { current_path }.to eq(profile_accountability_path)

        enable_trying_to_hide

        disable_trying_to_hide

        first_email_sent_to(user.email)
        expect(current_email.subject).to eq("#{progress_report_recipient.added_by_user.first_name} is trying to hide")
      end

      context 'and someone in "Slacking off" selector' do
        it "notifies user if I remove him from slacking off" do
          click_link 'Accountability'
          wait_for { current_path }.to eq(profile_accountability_path)

          enable_trying_to_hide

          enable_slacking_of_notification_for_user(user)

          within("#slacking-off") do
            sleep 1
            expect(find('#user_progress_report_recipient_id').value).to eq(progress_report_recipient.id.to_s)

            find('#user_progress_report_recipient_id').select('Select person from progress reports')
            click_button('Save')
          end

          first_email_sent_to(user.email)
          expect(current_email.subject).to eq("#{progress_report_recipient.added_by_user.first_name} is trying to hide")
        end

        it "notifies user if I remove him from slacking off and replace with someone else" do
          user2 = create(:user, organization: @user.organization)
          create(:progress_report_recipient, user: user2, added_by_user: @user)

          click_link 'Accountability'
          wait_for { current_path }.to eq(profile_accountability_path)

          enable_trying_to_hide

          enable_slacking_of_notification_for_user(user)

          #enable_slacking_of_notification_for_user(user2)
          within("#slacking-off") do
            expect(find('#user_progress_report_recipient_id').value).to eq(progress_report_recipient.id.to_s)

            find('#user_progress_report_recipient_id').select(user2.email)
            click_button('Save')
          end

          first_email_sent_to(user.email)
          expect(current_email.subject).to eq("#{progress_report_recipient.added_by_user.first_name} is trying to hide")
        end
      end
    end
  end

  def can_remove_progress_report_participant(name)
    expect(page).to have_content(progress_report_recipient.user.name)

    click_link 'Edit'

    page.accept_confirm do
      click_link("#{name} is no longer part of the team")
    end
    expect(page).to have_content("is no longer part of the team")

    visit current_path # reload

    expect(page).not_to have_content(progress_report_recipient.user.name)
  end

  def enable_slacking_of_notification_for_user(user)
    within("#slacking-off") do
      expect(find('#user_progress_report_recipient_id').value).to eq("")

      find('#user_progress_report_recipient_id').select(user.email)
      click_button('Save')
    end
  end

  def enable_trying_to_hide
    within("#trying-to-hide") do
      expect(find('#user_notify_observer_if_im_trying_to_hide').value).to eq("false")

      find('#user_notify_observer_if_im_trying_to_hide').select('Enabled')
      click_button('Save')
    end

    within("#trying-to-hide") do
      expect(find('#user_notify_observer_if_im_trying_to_hide').value).to eq("true")
    end
  end

  def disable_trying_to_hide
    within("#trying-to-hide") do
      expect(find('#user_notify_observer_if_im_trying_to_hide').value).to eq("true")

      find('#user_notify_observer_if_im_trying_to_hide').select('Disabled')
      click_button('Save')
    end

    within("#trying-to-hide") do
      expect(find('#user_notify_observer_if_im_trying_to_hide').value).to eq("false")
    end
  end
end
