# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'New(first) entry in NTC Elite group', type: :feature, js: true do
  let(:organization) { create(:organization, name: 'NTC Elite Group') }

  let(:mentor_user1) { create(:user, organization: organization, leaderbits_sending_enabled: false) }
  let(:mentee_user) { create(:user, organization: organization, leaderbits_sending_enabled: true) }

  let!(:organizational_mentorship) { OrganizationalMentorship.create! mentor_user: mentor_user1, mentee_user: mentee_user }

  context 'given 1st entry for mentor' do
    it 'sends notification with magic auto sign in link to mentor' do
      entry = create(:entry, discarded_at: nil, user: mentee_user)

      first_email_sent_to(mentor_user1.email)

      expect(current_email.subject).to eq("New entry for you to review")
      current_email.click_link('Click here')

      expect(page).to have_content(entry.content)

      #those users don't need that functionality
      expect(page).not_to have_content('Dashboard')
      expect(page).not_to have_content('My Points')

      # important here is that user is not forced to watch welcome video instead
      visit entry_groups_path

      expect(page).to have_content(entry.content)
      expect(page).to have_content('Total Entries')
    end
  end
end
