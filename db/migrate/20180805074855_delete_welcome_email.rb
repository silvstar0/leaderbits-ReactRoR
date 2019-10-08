# frozen_string_literal: true

class DeleteWelcomeEmail < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :date_to_send_welcome_email, :date, default: '2000-01-12'
  end
end
