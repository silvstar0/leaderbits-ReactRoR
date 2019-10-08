# frozen_string_literal: true

class NoNeedToPersistPostmarkMessageIds < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_sent_emails, :postmark_message_id
  end
end
