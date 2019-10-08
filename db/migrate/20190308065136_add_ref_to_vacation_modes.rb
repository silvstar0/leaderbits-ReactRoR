# frozen_string_literal: true

class AddRefToVacationModes < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :vacation_modes, :users

    add_foreign_key :anonymous_survey_completed_sessions, :users
    add_foreign_key :email_authentication_tokens, :users

    add_index :entry_replies, :user_id
    add_index :entry_replies, :entry_id

    change_column :entry_replies, :user_id, :bigint
    change_column :entry_replies, :entry_id, :bigint
  end
end
