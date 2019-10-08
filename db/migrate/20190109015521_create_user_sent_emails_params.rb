# frozen_string_literal: true

class CreateUserSentEmailsParams < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sent_emails, :params, :json
  end
end
