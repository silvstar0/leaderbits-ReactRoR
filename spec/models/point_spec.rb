# frozen_string_literal: true

# == Schema Information
#
# Table name: points
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)        not null
#  value          :integer          not null
#  type           :string           not null
#  pointable_type :string           not null
#  pointable_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Point, type: :model do
  describe 'validations' do
    example do
      user = create(:user)

      expect {
        described_class.create! value: 1,
                                type: Point::Types::ALL.sample,
                                user: user,
                                pointable: nil
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect {
        described_class.create! value: 1,
                                type: Point::Types::ALL.sample,
                                user: user,
                                pointable: create(:leaderbit)
      }.to change(Leaderbit, :count).to(1)
    end
  end
end
