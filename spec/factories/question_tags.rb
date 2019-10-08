# frozen_string_literal: true

# == Schema Information
#
# Table name: question_tags
#
#  id          :bigint(8)        not null, primary key
#  label       :string           not null
#  question_id :bigint(8)        not null
#  created_at  :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

FactoryBot.define do
  factory :question_tag do
    label { Faker::SlackEmoji.activity.delete(':').titleize }
    association :question, factory: :slider_question
  end
end
#ActiveRecord::Base.connection.select_value("select nextval('#{Leaderbit.sequence_name}')").to_i
