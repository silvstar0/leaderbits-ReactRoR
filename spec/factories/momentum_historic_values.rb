# frozen_string_literal: true

# == Schema Information
#
# Table name: momentum_historic_values
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  value      :integer          not null
#  created_on :date             not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :momentum_historic_value do
    user
    value { rand(0..100) }
    created_on { rand(1..20).days.ago.to_date }
  end
end
