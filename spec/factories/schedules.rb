# frozen_string_literal: true

# == Schema Information
#
# Table name: schedules
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  cloned_from_id :bigint(8)
#  users_count    :integer          default(0)
#
# Foreign Keys
#
#  fk_rails_...  (cloned_from_id => schedules.id)
#

FactoryBot.define do
  factory :schedule do
    sequence(:name) { |n| "Schedule #{n}" }
  end
end
