# frozen_string_literal: true

class CreateAnonymousSurveySessions < ActiveRecord::Migration[5.2]
  def change
    rename_table :anonymous_survey_emails, :anonymous_survey_participants

    rename_column :anonymous_survey_participants, :to_email, :email
    add_column :anonymous_survey_participants, :name, :string

    create_table :anonymous_survey_completed_sessions do |t|
      t.references :user
      t.string :by_user_with_email, null: false
      t.date :created_on, null: false
    end

    remove_column :anonymous_survey_participants, :survey_completed_at
  end
end
