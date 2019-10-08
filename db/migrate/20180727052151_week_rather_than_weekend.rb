# frozen_string_literal: true

class WeekRatherThanWeekend < ActiveRecord::Migration[5.2]
  def change
    if column_exists?(:users, :first_leaderbit_to_be_sent_during_weekend_that_starts_on)
      rename_column :users, :first_leaderbit_to_be_sent_during_weekend_that_starts_on, :first_leaderbit_to_be_sent_during_week_that_starts_on
    end
  end
end
