# frozen_string_literal: true

# == Schema Information
#
# Table name: organizational_mentorships
#
#  id             :bigint(8)        not null, primary key
#  mentor_user_id :bigint(8)        not null
#  mentee_user_id :bigint(8)        not null
#  created_at     :datetime         not null
#  accepted_at    :datetime
#
# Foreign Keys
#
#  fk_rails_...  (mentee_user_id => users.id)
#  fk_rails_...  (mentor_user_id => users.id)
#

FactoryBot.define do
  factory :organizational_mentorship do
    association :mentor_user, factory: :user
    association :mentee_user, factory: :user
    accepted_at { [Time.now, nil].sample }
  end
end
