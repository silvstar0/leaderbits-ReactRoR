# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_tags
#
#  id           :bigint(8)        not null, primary key
#  label        :string           not null
#  leaderbit_id :bigint(8)        not null
#  created_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#

FactoryBot.define do
  factory :leaderbit_tag do
    label { Faker::SlackEmoji.activity.delete(':').titleize }
    leaderbit
  end
end
