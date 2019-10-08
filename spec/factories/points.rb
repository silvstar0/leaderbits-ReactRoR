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

FactoryBot.define do
  factory :point do
    value { rand(1..50) }
    type { Point::Types::ALL.sample }
    user
    association :pointable, factory: :leaderbit
  end
end
