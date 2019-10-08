# frozen_string_literal: true

# == Schema Information
#
# Table name: hourly_leaderbit_sending_summaries
#
#  id                   :bigint(8)        not null, primary key
#  to_be_sent_quantity  :integer
#  actual_sent_quantity :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryBot.define do
  factory :hourly_leaderbit_sending_summary do
    to_be_sent_quantity { rand(0..100) }
    actual_sent_quantity { rand(0..100) }
  end
end
