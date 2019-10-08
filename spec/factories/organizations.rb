# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                                                                                                              :bigint(8)        not null, primary key
#  name                                                                                                            :string           not null
#  created_at                                                                                                      :datetime         not null
#  updated_at                                                                                                      :datetime         not null
#  first_leaderbit_introduction_message                                                                            :text
#  hour_of_day_to_send                                                                                             :integer          default(9)
#  day_of_week_to_send                                                                                             :string           default("Monday")
#  discarded_at                                                                                                    :datetime
#  custom_default_schedule_id                                                                                      :integer
#  leaderbits_sending_enabled                                                                                      :boolean          default(TRUE), not null
#  stripe_customer_id                                                                                              :string
#  active_since(needed in cases when organization is created prematurely but it must be activated on certain date) :datetime         not null
#  users_count                                                                                                     :integer
#

FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    hour_of_day_to_send { rand 7..10 }
    active_since { rand(1..24 * 3).hours.ago }
    day_of_week_to_send { %w(Monday Tuesday).sample }
    first_leaderbit_introduction_message { [nil, "Hi Team,\r\n\r\n    I’m writing to let you know #{Faker::Hacker.say_something_smart}"].sample }
    leaderbits_sending_enabled { true }
  end
end
