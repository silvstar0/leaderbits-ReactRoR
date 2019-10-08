# frozen_string_literal: true

class AddPositionToLeaderbit < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :hour_of_day_to_send, nil

    add_column :leaderbits, :position, :integer
    add_column :users, :first_leaderbit_to_be_sent_during_week_that_starts_on, :date

    remove_column :users, :leaderbit_id_to_send, :integer, default: 1
    remove_column :users, :date_to_send_leaderbit, :date
  end
end
