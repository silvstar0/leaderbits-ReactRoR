# frozen_string_literal: true

class AddRoleToAnonymousSurveyParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :anonymous_survey_participants, :role, :string
    change_column_null :anonymous_survey_participants, :role, false
  end
end
