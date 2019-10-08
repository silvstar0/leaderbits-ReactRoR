# frozen_string_literal: true

# == Schema Information
#
# Table name: entry_groups
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :entry_group do
    leaderbit
    user
  end
end
