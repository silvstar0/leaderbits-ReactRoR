# frozen_string_literal: true

class AddDateToSendWelcomeEmailToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :date_to_send_welcome_email, :date, default: "12-1-2000"
    add_column :accounts, :hour_of_day_to_send, :integer, default: 9
  end
end
