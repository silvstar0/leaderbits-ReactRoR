# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_schedules
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  schedule_id  :bigint(8)        not null
#  position     :integer
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (schedule_id => schedules.id)
#

FactoryBot.define do
  factory :leaderbit_schedule do
    leaderbit
    schedule
  end
end
