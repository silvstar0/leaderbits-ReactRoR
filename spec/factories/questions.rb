# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id                               :bigint(8)        not null, primary key
#  survey_id                        :bigint(8)        not null
#  params                           :json             not null
#  position                         :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  anonymous_survey_similarity_uuid :string
#  count_as_reverse                 :boolean          default(FALSE)
#
# Foreign Keys
#
#  fk_rails_...  (survey_id => surveys.id)
#

FactoryBot.define do
  factory :slider_question, class: Question do
    survey
    params do
      title = [
        "How strongly do you agree with this statement: #{Faker::Hacker.say_something_smart}",
        Faker::Hacker.say_something_smart
      ].sample

      hint = [nil, "0 is not at all"].sample
      { "title" => title, "hint" => hint, "left_side" => 0, "right_side" => 10, "type" => Question::Types::SLIDER }
    end
    count_as_reverse { [true, false].sample }
  end

  factory :single_textbox_question, class: Question do
    survey
    params do
      title = [
        Faker::Hacker.say_something_smart,
        "Are you like a tech CEO or a world leader?",
        "More like Steve Jobs or Gandhi?",
        "Is your leadership style creative or rigid?",
        "People first or goals first?"
      ].sample

      { "title" => title, "type" => Question::Types::SINGLE_TEXTBOX }
    end
    count_as_reverse { [true, false].sample }
  end

  factory :commentbox_question, class: Question do
    survey
    params do
      title = [
        Faker::Hacker.say_something_smart,
        "List 33 ways something could be improved",
      ].sample

      { "title" => title, "type" => Question::Types::COMMENT_BOX }
    end
    count_as_reverse { [true, false].sample }
  end
end
