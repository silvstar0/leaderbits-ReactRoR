# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id                                :bigint(8)        not null, primary key
#  type                              :string           not null
#  title                             :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  anonymous_survey_participant_role :string
#

FactoryBot.define do
  factory :survey do
    type { Survey::Types::ALL.sample }
    sequence(:title) { |n| "Survey#{n}" }
  end
end
