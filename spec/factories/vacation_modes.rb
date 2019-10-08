# frozen_string_literal: true

# == Schema Information
#
# Table name: vacation_modes
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  reason     :text
#  starts_at  :datetime         not null
#  ends_at    :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :vacation_mode do
    user
    starts_at { 1.day.from_now.to_date }
    ends_at { 10.days.from_now.to_date }
    reason { Faker::Hacker.say_something_smart }
  end
end
