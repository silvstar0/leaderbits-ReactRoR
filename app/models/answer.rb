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

class Answer < ApplicationRecord
  #NOTE: user is nil in case when this is an answer from "anonymous" user rather than leader-user
  belongs_to :user, optional: true
  belongs_to :anonymous_survey_participant, optional: true
  belongs_to :question

  validates :params, presence: true, allow_nil: false, allow_blank: false

  #validates :user, uniqueness: { scope: :question }, allow_nil: true, allow_blank: false

  #NOTE: anonymous_survey_participant is nil in case when this is an answer from leader-user rather than "anonymous" user
  #validates :anonymous_survey_participant, uniqueness: { scope: :question }, allow_nil: true, allow_blank: false

  validate :validate_answer_type

  private

  def by_anonymous_user?
    anonymous_survey_participant.present? && user.blank?
  end

  def by_team_leader?
    anonymous_survey_participant.blank? && user.present?
  end

  def validate_answer_type
    return if by_anonymous_user?
    return if by_team_leader?

    errors.add(:user, "unknown type of answer.")
    raise ActiveRecord::RecordInvalid, self
  end
end
