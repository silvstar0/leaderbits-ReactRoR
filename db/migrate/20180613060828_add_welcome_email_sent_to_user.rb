# frozen_string_literal: true

class AddWelcomeEmailSentToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :welcome_email_sent, :bool, default: false
  end
end
