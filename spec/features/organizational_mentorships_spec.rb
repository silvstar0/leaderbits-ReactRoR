# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizational Mentorships', type: :feature, js: true do
  describe 'accept mentee invitation' do
    let(:schedule) { create(:schedule, name: Schedule::GLOBAL_NAME) }
    let!(:leaderbit) { create(:active_leaderbit).tap { |l| schedule.leaderbit_schedules.create! leaderbit: l } }

    let(:user) { create(:user, schedule: schedule, name: "John Brown") }

    #TODO delete it after some time because we don't care much about year old email links
    context 'given new invitation with old routing' do
      let(:organizational_mentorship) { create(:organizational_mentorship, mentee_user: user, accepted_at: false) }

      example do
        old_path = "/user_mentees/#{organizational_mentorship.id}/accept?" + { user_email: organizational_mentorship.mentee_user.email, user_token: organizational_mentorship.mentee_user.authentication_token }.to_query
        puts old_path
        visit old_path

        expect(page).to have_content("Invitation has been accepted")
        expect(page).to have_content("You will receive an email with your first LeaderBit shortly.")
        expect(organizational_mentorship.reload.accepted_at).to be_present
      end
    end

    context 'given new invitation with old routing' do
      let(:organizational_mentorship) { create(:organizational_mentorship, mentee_user: user, accepted_at: false) }

      example do
        old_path = "/mentorships/#{organizational_mentorship.id}/accept?" + { user_email: organizational_mentorship.mentee_user.email, user_token: organizational_mentorship.mentee_user.authentication_token }.to_query
        puts old_path
        visit old_path

        expect(page).to have_content("Invitation has been accepted")
        expect(page).to have_content("You will receive an email with your first LeaderBit shortly.")
        expect(organizational_mentorship.reload.accepted_at).to be_present
      end
    end

    context 'given new invitation' do
      let(:organizational_mentorship) { create(:organizational_mentorship, mentee_user: user, accepted_at: false) }

      example do
        visit accept_organizational_mentorship_path(id: organizational_mentorship.id,
                                                    user_email: organizational_mentorship.mentee_user.email,
                                                    user_token: organizational_mentorship.mentee_user.authentication_token)

        expect(page).to have_content("Invitation has been accepted")
        expect(page).to have_content("You will receive an email with your first LeaderBit shortly.")
        expect(organizational_mentorship.reload.accepted_at).to be_present
      end
    end

    context 'given already accepted invitation' do
      let(:organizational_mentorship) { create(:organizational_mentorship, mentee_user: user, accepted_at: 2.seconds.ago) }

      example do
        visit accept_organizational_mentorship_path(id: organizational_mentorship.id,
                                                    user_email: organizational_mentorship.mentee_user.email,
                                                    user_token: organizational_mentorship.mentee_user.authentication_token)

        expect(page).to have_content("Invitation has been accepted")
        expect(page).to have_content("You will receive an email with your first LeaderBit shortly.")
        expect(organizational_mentorship.reload.accepted_at).to be_present
      end
    end
  end
end
