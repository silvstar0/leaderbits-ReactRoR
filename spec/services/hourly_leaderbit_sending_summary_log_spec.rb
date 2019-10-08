# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HourlyLeaderbitSendingSummaryLog do
  context 'given quiet 2 hours with no plans' do
    example do
      described_class.call

      all = HourlyLeaderbitSendingSummary.all.order(created_at: :asc)

      current_hour_summary = all[0]
      next_hour_summary = all[1]

      expect(next_hour_summary.created_at - current_hour_summary.created_at).to eq(1.hour)

      expect(current_hour_summary.created_at.in_time_zone(Time.zone)).to be_within(1.second).of(Time.zone.now)
      expect(current_hour_summary.to_be_sent_quantity).to eq(0)
      expect(current_hour_summary.actual_sent_quantity).to eq(nil)
    end
  end

  context 'given some leaderbits to send' do
    let(:user) { create(:user, leaderbits_sending_enabled: true, organization: create(:organization, active_since: 2.days.ago, leaderbits_sending_enabled: true)) }

    before do
      allow(described_class).to receive(:send_during_this_hour?).with(user).and_return(true)

      create :user_sent_scheduled_new_leaderbit, user: user, resource: create(:leaderbit)
      create :user_sent_scheduled_new_leaderbit, user: user, resource: create(:leaderbit)
    end

    example do
      expect { described_class.call }.to change(HourlyLeaderbitSendingSummary, :count).from(0)

      all = HourlyLeaderbitSendingSummary.all.order(created_at: :asc)
      expect(all.size).to be > 0

      prev_hour_summary = all[0]
      current_hour_summary = all[1]

      expect(current_hour_summary.created_at - prev_hour_summary.created_at).to eq(1.hour)

      expect(current_hour_summary.to_be_sent_quantity).to eq(1)
      expect(current_hour_summary.actual_sent_quantity).to eq(nil)
    end
  end
end
