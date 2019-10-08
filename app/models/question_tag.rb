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

class QuestionTag < ApplicationRecord
  belongs_to :question

  audited

  validates :label, uniqueness: { scope: :question }, presence: true
end
