# frozen_string_literal: true

# == Schema Information
#
# Table name: preemptive_leaderbits
#
#  id               :bigint(8)        not null, primary key
#  leaderbit_id     :bigint(8)        not null
#  user_id          :bigint(8)        not null
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  added_by_user_id :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe PreemptiveLeaderbit, type: :model do
  describe 'validations' do
    example do
      user = create(:user)
      leaderbit = create(:leaderbit)

      create(:preemptive_leaderbit, user: user, leaderbit: leaderbit)

      expect { create(:preemptive_leaderbit, user: user, leaderbit: leaderbit) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'cache invalidation' do
    it 'invalidates user cache' do
      user = create(:user)

      expect { create(:preemptive_leaderbit, user: user) }.to change { user.reload.cache_key_with_version }
    end

    it 'does not invalidate leaderbit cache' do
      leaderbit = create(:leaderbit)

      expect { create(:preemptive_leaderbit, leaderbit: leaderbit) }.not_to change { leaderbit.reload.cache_key_with_version }
    end
  end

  describe 'acts_as_list position handling/configuration' do
    it 'is per user scoped' do
      user = create(:user)

      user1 = create(:user)
      user2 = create(:user)

      leaderbit1 = create(:leaderbit, id: 111)
      leaderbit2 = create(:leaderbit, id: 222)

      user1.preemptive_leaderbits.create! leaderbit: leaderbit1, added_by_user: user
      user1.preemptive_leaderbits.create! leaderbit: leaderbit2, added_by_user: user

      expect(user1.preemptive_leaderbits.pluck(:leaderbit_id, :position)).to contain_exactly [leaderbit1.id, 1], [leaderbit2.id, 2]

      expect do
        user2.preemptive_leaderbits.create! leaderbit: leaderbit2, added_by_user: user
        user2.preemptive_leaderbits.create! leaderbit: leaderbit1, added_by_user: user
      end.not_to change { user1.preemptive_leaderbits.pluck(:leaderbit_id, :position) }

      expect(user2.preemptive_leaderbits.pluck(:leaderbit_id, :position)).to contain_exactly [leaderbit2.id, 1], [leaderbit1.id, 2]
    end
  end
end
