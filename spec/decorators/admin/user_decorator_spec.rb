# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserDecorator do
  describe '#challenges_sent_but_not_completed' do
    example do
      schedule = create(:schedule)

      user = create(:user, schedule: schedule)

      leaderbit1 = create(:leaderbit, active: true)
      leaderbit2 = create(:leaderbit, active: true)

      schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      schedule.leaderbit_schedules.create! leaderbit: leaderbit2

      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1)
      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit2)

      expect do
        create(:leaderbit_log,
               leaderbit: leaderbit1,
               user: user,
               status: LeaderbitLog::Statuses::COMPLETED)
      end.to change { described_class.new(user).challenges_sent_but_not_completed }.from(2).to(1)
    end
  end

  describe '#total_time_watched' do
    let(:user) { create(:user) }
    let(:leaderbit1) { create(:leaderbit) }
    let(:leaderbit2) { create(:leaderbit) }

    example do
      create(:leaderbit_video_usage, user: create(:user), leaderbit: leaderbit1, video_session_id: 'anotherusersess', seconds_watched: 99)

      create(:leaderbit_video_usage, user: user, leaderbit: leaderbit1, video_session_id: 'sess1', seconds_watched: 1)
      create(:leaderbit_video_usage, user: user, leaderbit: leaderbit1, video_session_id: 'sess2', seconds_watched: 10)

      expect do
        create(:leaderbit_video_usage, user: user, leaderbit: leaderbit2, video_session_id: 'sess3', seconds_watched: 30)
      end.to change { described_class.new(user).total_time_watched }.from("11 secs<br>(less than a minute)").to("41 secs<br>(1 minute)")
    end
  end

  describe '#challenges_watched_but_not_completed' do
    let(:user) { create(:user) }
    let(:leaderbit1) { create(:leaderbit) }
    let(:leaderbit2) { create(:leaderbit) }

    example do
      expect(described_class.new(user).challenges_watched_but_not_completed).to eq(0)

      create(:leaderbit_video_usage, user: user, leaderbit: leaderbit1, video_session_id: 'sess1')
      create(:leaderbit_video_usage, user: user, leaderbit: leaderbit2, video_session_id: 'sess2')

      expect { create(:leaderbit_log, user: user, leaderbit: leaderbit1, status: LeaderbitLog::Statuses::COMPLETED) }.to change { described_class.new(user).challenges_watched_but_not_completed }
                                                                                                                           .from(2)
                                                                                                                           .to(1)

      expect { create(:leaderbit_log, user: user, leaderbit: leaderbit2, status: LeaderbitLog::Statuses::COMPLETED) }.to change { described_class.new(user).challenges_watched_but_not_completed }
                                                                                                                           .from(1)
                                                                                                                           .to(0)
    end
  end
end
