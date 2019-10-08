# frozen_string_literal: true

class RenameSurveyInvitations < ActiveRecord::Migration[5.2]
  def change
    rename_column :survey_invitations, :user_id, :added_by_user_id

    rename_table :survey_invitations, :anonymous_survey_emails
  end
end
