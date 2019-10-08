# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckIfActiveRecipientHasAnyKindOfLeaderbitToReceive do
  let(:user) { create(:user, personalized_leaderbits_algorithm_instead_of_regular_schedule: false, schedule: schedule) }
  let!(:schedule) { create(:schedule) }

  let!(:leaderbit) do
    create(:leaderbit, active: true).tap do |l|
      schedule.leaderbit_schedules.create! leaderbit: l
      create(:user_sent_scheduled_new_leaderbit, user: user, resource: l)
    end
  end

  context 'given one incomplete leaderbit that we have not notified about yet' do
    example do
      expect {
        described_class.call
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  context 'given one incomplete leaderbit that we have already notified about' do
    example do
      create(:user_sent_incomplete_leaderbit_reminder, user: user, resource: leaderbit)

      expect {
        described_class.call
      }.to change { ActionMailer::Base.deliveries.count }.from(0).to(1)
             .and change { ActionMailer::Base.deliveries.last&.subject }.from(nil).to("Warning: not enough LeaderBits to send to 1 user")
    end
  end
end
