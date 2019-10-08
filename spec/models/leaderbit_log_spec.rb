# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_logs
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  status       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe LeaderbitLog, type: :model do
  describe 'validations' do
    let(:leaderbit) { create(:leaderbit) }

    describe 'log uniqueness in (ll ; leaderbit ; status) combination' do
      let(:user) { create(:user) }

      example do
        create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::IN_PROGRESS)

        expect {
          create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::COMPLETED)
        }.not_to raise_error # (ActiveRecord::RecordInvalid)
      end

      example do
        create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::IN_PROGRESS)

        expect {
          create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::IN_PROGRESS)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      example do
        create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::COMPLETED)

        expect {
          create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::COMPLETED)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#completed!' do
    example do
      leaderbit_log = create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS)

      expect {
        leaderbit_log.completed!
      }.to change { leaderbit_log.reload.status }.from(LeaderbitLog::Statuses::IN_PROGRESS).to(LeaderbitLog::Statuses::COMPLETED)
    end
  end
end
