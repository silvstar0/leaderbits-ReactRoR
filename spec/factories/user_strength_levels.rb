# frozen_string_literal: true

# == Schema Information
#
# Table name: user_strength_levels
#
#  id          :bigint(8)        not null, primary key
#  symbol_name :string
#  user_id     :bigint(8)        not null
#  value       :integer
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :user_strength_level do
    user
    symbol_name { StrengthLevelsFormObject::Levels::ALL.sample }

    value { rand(0..100) }
  end
end
