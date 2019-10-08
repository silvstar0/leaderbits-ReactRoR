# frozen_string_literal: true

# == Schema Information
#
# Table name: boomerang_leaderbits
#
#  id           :bigint(8)        not null, primary key
#  type         :string           not null
#  user_id      :bigint(8)        not null
#  leaderbit_id :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe BoomerangLeaderbit, type: :model do
  describe '#boomerang_to_be_sent_on_date' do
    subject do
      described_class
        .new(created_at: created_at, type: described_class::Types::COUPLE_DAYS)
        .boomerang_to_be_sent_on_date
    end

    let(:tz_name) { 'London' }
    let(:created_at) { monday_time(tz_name: tz_name) }

    it { is_expected.to eq(2.days.since(created_at).to_date) }
  end

  describe 'validations' do
    example do
      leaderbit1 = create(:leaderbit)
      user1 = create(:user)

      described_class.create! leaderbit: leaderbit1,
                              user: user1,
                              type: described_class::Types::COUPLE_DAYS

      expect do
        described_class.create! leaderbit: leaderbit1,
                                user: user1,
                                type: described_class::Types::COUPLE_DAYS
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
