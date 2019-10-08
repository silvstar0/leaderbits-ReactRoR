# frozen_string_literal: true

class EnforceUserMenteesCreatedAt < ActiveRecord::Migration[5.2]
  def change
    change_column_null :user_mentees, :created_at, false
    change_column_null :anonymous_survey_participants, :created_at, false
    change_column_null :api_usages, :created_at, false
    change_column_null :boomerang_leaderbits, :created_at, false
    change_column_null :email_authentication_tokens, :created_at, false
    change_column_null :leaderbit_video_usages, :created_at, false

    change_column_null :boomerang_leaderbits, :updated_at, false
  end
end
