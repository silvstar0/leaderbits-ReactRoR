# frozen_string_literal: true

# == Schema Information
#
# Table name: schedules
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  cloned_from_id :bigint(8)
#  users_count    :integer          default(0)
#
# Foreign Keys
#
#  fk_rails_...  (cloned_from_id => schedules.id)
#

require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'cache invalidation' do
    it 'invalidates all its users on new leaderbit' do
      schedule = create(:schedule)
      user1 = create(:user, schedule: schedule)
      user2 = create(:user)
      original_user2_cache_key = user2.cache_key_with_version

      expect { schedule.leaderbit_schedules.create! leaderbit: create(:leaderbit) }.to change { user1.reload.cache_key_with_version }
      expect(user2.reload.cache_key_with_version).to eq(original_user2_cache_key)
    end

    it 'invalidates all its users on adjusted schedule' do
      schedule = create(:schedule)
      user1 = create(:user, schedule: schedule)
      leaderbit = create(:leaderbit)
      schedule.leaderbit_schedules.create! leaderbit: leaderbit

      user2 = create(:user)
      original_user2_cache_key = user2.cache_key_with_version

      expect { LeaderbitSchedule.last.destroy }.to change { user1.reload.cache_key_with_version }

      expect(user2.reload.cache_key_with_version).to eq(original_user2_cache_key)
    end
  end

  describe 'destroy' do
    example do
      leaderbit = create(:leaderbit)

      schedule1 = create(:schedule)
      schedule2 = create(:schedule)

      schedule1.leaderbit_schedules.create! leaderbit: leaderbit
      schedule2.leaderbit_schedules.create! leaderbit: leaderbit

      expect { schedule1.destroy }.to change(LeaderbitSchedule, :count).from(2).to(1)
      expect(leaderbit.reload.persisted?).to eq(true)
    end
  end
end
