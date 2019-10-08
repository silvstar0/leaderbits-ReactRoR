# frozen_string_literal: true

class CleanupHourToSend < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :hour_of_day_to_send, false
    change_column_null :users, :day_of_week_to_send, false
  end
end
