# frozen_string_literal: true

class AddMessageIdToSentEmails < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sent_emails, :postmark_message_id, :string
  end
end
