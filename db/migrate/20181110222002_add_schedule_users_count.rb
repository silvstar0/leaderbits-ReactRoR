# frozen_string_literal: true

class AddScheduleUsersCount < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :users_count, :integer, default: 0
  end
end
