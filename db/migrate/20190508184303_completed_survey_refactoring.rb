# frozen_string_literal: true

class CompletedSurveyRefactoring < ActiveRecord::Migration[5.2]
  def change
    drop_table :anonymous_survey_completed_sessions

    add_reference :answers, :anonymous_survey_participant
  end
end
