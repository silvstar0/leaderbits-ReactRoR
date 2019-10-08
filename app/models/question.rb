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

class Question < ApplicationRecord
  # @see https://github.com/swanandp/acts_as_list
  acts_as_list scope: :survey

  audited

  belongs_to :survey

  with_options dependent: :destroy do
    has_many :answers
    has_many :tags, class_name: 'QuestionTag'
  end

  validates :params, presence: true, allow_nil: false, allow_blank: false

  module Types
    SINGLE_TEXTBOX = 'single-textbox'
    COMMENT_BOX = 'comment-box'
    SLIDER = 'slider'
  end

  def title
    params['title']
  end

  def type
    params['type']
  end

  # optional
  def hint
    params['hint']
  end

  # optional, for slider
  def left_side
    params['left_side'] #.to_i
  end

  # optional, for slider
  def right_side
    params['right_side'] #.tap { |value| Rails.logger.debug("#{self.inspect}") if right_side.to_i.zero? }
  end

  def mandatory?
    #TODO-low simplify
    params['mandatory'] || params['is_mandatory']
  end

  # @return [String] array of strings
  def selected_tag_labels
    tags.pluck(:label)
  end

  def to_react_component_params
    url = persisted? ? Rails.application.routes.url_helpers.admin_survey_question_path(survey, self) : Rails.application.routes.url_helpers.admin_survey_questions_path(survey)

    {
      id: id,
      url: url,
      title: title || "",
      type: type || Question::Types::SINGLE_TEXTBOX,
      mandatory: mandatory? || true,

      left_side: left_side || "",
      right_side: right_side || "",
      hint: hint || "",

      # for passing down to TagSelector
      allLabels: all_global_tag_labels,
      selectedLabels: selected_tag_labels
    }
  end
end
