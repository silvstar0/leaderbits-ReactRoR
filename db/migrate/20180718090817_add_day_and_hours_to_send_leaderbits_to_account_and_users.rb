# frozen_string_literal: true

class AddDayAndHoursToSendLeaderbitsToAccountAndUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :day_of_week_to_send, :string, default: "Monday"
    add_column :users, :day_of_week_to_send, :string
  end
end
