# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_logs
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  status       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :leaderbit_log do
    leaderbit
    user
    status { LeaderbitLog::Statuses::ALL.sample }
  end
end
