# frozen_string_literal: true

class RemoveUserSentEmailForeignReference < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :user_sent_emails, column: "resource_id"
  end
end
