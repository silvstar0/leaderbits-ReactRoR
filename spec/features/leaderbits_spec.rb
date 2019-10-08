# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Leaderbits', type: :feature, js: true do
  context "Entry#show page(accessible from EntryReplyMailer#new_reply" do
    let(:entry) { create(:entry, discarded_at: nil, content: 'Entry Content') }
    let!(:entry_reply) { create(:entry_reply, content: 'Entry Reply', entry: entry, user: user, parent_reply_id: nil) }
    let!(:reply_on_reply) { create(:entry_reply, content: 'Reply on Reply', entry: entry, parent_reply_id: entry_reply.id) }
    let(:user) { create(:system_admin_user, leaderbits_sending_enabled: false) }

    before do
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'display original entry, all replies and replies to replies' do
      visit entry_path(entry.to_param)

      #sleep 1
      expect(page).to have_content(entry.content)

      expect(page).to have_content(entry_reply.content)
      expect(page).to have_content(reply_on_reply.content)
    end
  end

  context 'On All Challenges page' do
    let(:leaderbit) { create(:leaderbit) }
    let(:leaderbit2) { create(:leaderbit) }

    before do
      user = create(:user, leaderbits_sending_enabled: false)
      login_as(user, scope: :user, run_callbacks: false)

      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
    end

    it 'can start unstarted leaderbit' do
      visit leaderbits_path
      expect(page).to have_content 'All challenges'

      expect(page).to have_content leaderbit.name

      click_link('Start LeaderBit')
      sleep 1
      #wait_for { current_path }.to eq(leaderbit_path(leaderbit))

      expect_leaderbit_start_message
    end
  end

  context 'Leaderbits#show page' do
    context 'signed in as regular user' do
      before do
        @user = create(:team_member_user, leaderbits_sending_enabled: false)
        login_as(@user, scope: :user, run_callbacks: false)
      end

      it 'displays full body on *Read* (more) click' do
        leaderbit = create(:active_leaderbit)

        create(:user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit)

        visit leaderbit_path(leaderbit)

        press 'Read'
        expect(page).to have_content(leaderbit.body)
      end
    end

    context 'signed in as team member' do
      before do
        @user = create(:team_member_user, name: 'Entry Author1', leaderbits_sending_enabled: false)
        login_as(@user, scope: :user, run_callbacks: false)

        # so that you can access it
        create(:user_sent_scheduled_new_leaderbit, user: @user, resource: entry.leaderbit)
      end

      let(:entry) { create(:entry, discarded_at: nil, visible_to_my_peers: true, content: 'Entry Content', user: @user) }

      context 'My Entries' do
        it 'can can see replies and likes to my entry, reply to replies', skip: ENV['CI'].present? do
          expect(all_emails).to be_blank

          system_admin_user = create(:system_admin_user, name: 'System Admin1', organization: @user.organization)
          reply = create(:entry_reply, content: 'Entry Reply', entry: entry, user: system_admin_user)

          # it email notifies original entry author about new reply
          first_subject = "#{system_admin_user.name} Replied to You - #{entry.leaderbit.name}"
          expect(all_emails.collect(&:subject)).to eq([first_subject])
          expect(all_emails[0].to).to eq([entry.user.email])

          entry.liked_by system_admin_user
          entry.liked_by create(:system_admin_user)

          user3 = create(:user) # as if it his team leader
          entry.liked_by user3

          visit leaderbit_path(entry.leaderbit.to_param)

          expect(page).to have_content('My Entries')
          expect(page).to have_content(entry.content)

          sleep 2 #do not remove, it keeps failing on CI and keeps failing locally. Try increasing sleep time
          expect(page).to have_content(reply.content)
          expect(page).to have_content("#{system_admin_user.name} liked this entry")

          press 'Reply'

          fill_in with: "My Reply to Reply #{reply.content}", class: 'reply_content'

          press 'Send Reply'
          sleep 1

          # it email notifies because of new reply - reply on reply
          second_subject = "#{@user.name} Replied to You - #{entry.leaderbit.name}"
          expect(all_emails.collect(&:subject)).to eq([first_subject, second_subject])
          expect(all_emails[1].to).to eq([system_admin_user.email])

          visit current_path # reload # show page

          expect(page).to have_content 'My Reply to Reply'
        end

        it 'can edit entry' do
          visit leaderbit_path(entry.leaderbit.to_param)

          expect(page).to have_content(entry.content)
          #sleep 1

          press('Edit')

          fill_in with: "My Updated Entry", class: 'edit_entry'
          sleep 1

          click_button 'Update Entry'
          sleep 1

          visit current_path # reload # show page
          expect(page).not_to have_content(entry.content)
          expect(page).to have_content('My Updated Entry')
        end
      end
    end
  end
end
