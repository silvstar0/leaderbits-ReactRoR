# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id                                                                                        :bigint(8)        not null, primary key
#  user_id(Present in case that is leader-user answering Survey::Types::FOR_LEADER question) :bigint(8)
#  question_id                                                                               :bigint(8)        not null
#  params                                                                                    :json             not null
#  created_at                                                                                :datetime         not null
#  updated_at                                                                                :datetime         not null
#  anonymous_survey_participant_id(mandatory for answers to anonymous survey)                :bigint(8)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  trait :generic_answer do
    association :question, factory: :commentbox_question
    params { { "title" => "What level of individual ownership do you feel on your current project?", "type" => Question::Types::COMMENT_BOX } }
  end

  factory :answer_by_leader, class: Answer do
    generic_answer

    anonymous_survey_participant { nil }
    user
  end

  factory :anonymous_answer, class: Answer do
    generic_answer

    anonymous_survey_participant
    user { nil }
  end
end
