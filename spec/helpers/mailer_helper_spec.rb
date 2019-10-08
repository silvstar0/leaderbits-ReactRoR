# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailerHelper, type: :helper do
  describe '#complete_a_challenge_text' do
    subject { helper.complete_a_challenge_text_in_dont_quit_email(user) }

    let(:user) { create(:user) }
    let(:leaderbit) { create(:leaderbit) }

    context "in case user doesn't have an in-progress challenge" do
      it { is_expected.to eq("complete a challenge") }
    end

    context "in case user doesn't have an in-progress challenge" do
      let!(:leaderbit_log) { create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit, user: user) }

      it { is_expected.to start_with('<a href=') }
      it { is_expected.to end_with('</a>') }
      it { is_expected.to match(/complete a challenge/) }
    end

    context "in case user doesn't have an in-progress challenge but received leaderbit email" do
      let!(:user_lent_leaderbit) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit) }

      it { is_expected.to start_with('<a href=') }
      it { is_expected.to end_with('</a>') }
      it { is_expected.to match(/complete a challenge/) }
    end
  end

  describe '#missed_weeks_quantity' do
    let(:organization) { create(:organization, active_since: 7.weeks.ago) }

    context 'given completely inactive user' do
      subject { helper.missed_weeks_quantity(user) }

      let(:user) { create(:user, created_at: created_at, organization: organization) }

      context '' do
        let(:created_at) { 1.day.until(2.weeks.ago) }

        it { is_expected.to eq('2 weeks') }
      end

      context '' do
        let(:created_at) { 2.weeks.ago }

        it { is_expected.to eq('2 weeks') }
      end

      context '' do
        let(:created_at) { 1.day.since(2.weeks.ago) }

        it { is_expected.to eq('1 week') }
      end
    end
  end

  context 'given with some old activity' do
    let(:organization) { create(:organization, active_since: 7.weeks.ago) }

    example do
      user1 = create(:user, created_at: 29.days.ago, organization: organization)

      expect(helper.missed_weeks_quantity(user1)).to eq('4 weeks')

      create(:leaderbit_log, user: user1, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 15.days.ago)
      expect(helper.missed_weeks_quantity(user1)).to eq('2 weeks')
    end
  end
end
