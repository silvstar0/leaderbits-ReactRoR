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

require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'validations' do
    let(:question) { create(:commentbox_question) }

    it 'prevents multiple answers to the same question by the same user' do
      user = create(:user)

      create(:answer_by_leader, user: user, question: question)

      #NOTE: this validation has moved to controller level
      #expect { create(:answer_by_leader, user: user, question: question) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'could belong to *anonymous* user rather than actual leader-user' do
      anonymous_survey_participant = create(:anonymous_survey_participant)

      create(:anonymous_answer, anonymous_survey_participant: anonymous_survey_participant, question: question)
      #NOTE: this validation has moved to controller level
      #expect { create(:anonymous_answer, anonymous_survey_participant: anonymous_survey_participant, question: question) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects answers that is not anonymous and not of leader-user' do
      expect do
        described_class.create! question: create(:commentbox_question),
                                params: { "title" => "What level of individual ownership do you feel on your current project?", "type" => Question::Types::COMMENT_BOX },
                                anonymous_survey_participant: nil,
                                user: nil
      end.to raise_error(ActiveRecord::RecordInvalid, /unknown type of answer/)
    end
  end
end
