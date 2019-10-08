# frozen_string_literal: true

# == Schema Information
#
# Table name: preemptive_leaderbits
#
#  id               :bigint(8)        not null, primary key
#  leaderbit_id     :bigint(8)        not null
#  user_id          :bigint(8)        not null
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  added_by_user_id :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :preemptive_leaderbit do
    user
    leaderbit
    association :added_by_user, factory: :user
  end
end
