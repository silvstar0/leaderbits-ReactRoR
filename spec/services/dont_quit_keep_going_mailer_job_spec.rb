# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DontQuitKeepGoingMailerJob do
  let(:organization) { create(:organization, active_since: 4.weeks.ago) }

  let!(:user) { create(:user, created_at: 20.days.ago, schedule: schedule, organization: organization) }
  let(:schedule) { Schedule.create!(name: Schedule::GLOBAL_NAME).tap { |schedule| schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit) } }

  it 'creates user_sent_dont_quit record' do
    expect { described_class.call }.to change(UserSentDontQuit, :count).to(1)
    expect(UserSentDontQuit.last.created_at).to be_within(1.second).of(Time.zone.now)
  end

  context 'given recently sent *dont quit. keep going* mail' do
    it 'skips sending again if less than 2 weeks passed' do
      user.user_sent_dont_quits.create! created_at: 13.day.ago

      expect { described_class.call }.not_to change(UserSentDontQuit, :count)
    end

    it 'sends again again if more than 2 weeks passed' do
      user.user_sent_dont_quits.create! created_at: 15.day.ago

      expect { described_class.call }.to change(UserSentDontQuit, :count).from(1).to(2)
    end
  end
end
