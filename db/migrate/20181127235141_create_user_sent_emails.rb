# frozen_string_literal: true

class CreateUserSentEmails < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_sent_leaderbits, :user_sent_emails

    rename_column :user_sent_emails, :leaderbit_id, :resource_id
    rename_column :user_sent_emails, :sent_at, :created_at
    add_column :user_sent_emails, :resource_type, :string
    add_column :user_sent_emails, :type, :string
  end
end
