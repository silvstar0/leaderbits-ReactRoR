# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_employee_mentorships
#
#  id             :bigint(8)        not null, primary key
#  mentor_user_id :bigint(8)
#  mentee_user_id :bigint(8)
#  created_at     :datetime
#
# Foreign Keys
#
#  fk_rails_...  (mentee_user_id => users.id)
#  fk_rails_...  (mentor_user_id => users.id)
#

FactoryBot.define do
  factory :leaderbit_employee_mentorship do
    association :mentor_user, factory: :user
    association :mentee_user, factory: :user
  end
end
