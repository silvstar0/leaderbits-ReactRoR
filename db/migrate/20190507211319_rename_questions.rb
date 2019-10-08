# frozen_string_literal: true

class RenameQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :anonymous_survey_participant_role, :string
    add_column :questions, :anonymous_survey_similarity_uuid, :string
  end
end
