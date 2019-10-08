# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :date_to_send_leaderbit, :date
    add_column :users, :leaderbit_to_send, :integer
    add_column :users, :hour_of_day_to_send, :integer, default: "09"
  end
end
