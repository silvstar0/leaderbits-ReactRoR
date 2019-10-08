# frozen_string_literal: true

class MoreForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :leaderbit_schedules, :schedules

    change_column :preemptive_leaderbits, :added_by_user_id, :bigint

    change_column :schedules, :cloned_from_id, :bigint

    add_foreign_key :schedules, :schedules, column: :cloned_from_id

    change_column :leaderbit_schedules, :leaderbit_id, :bigint
    change_column :leaderbit_schedules, :schedule_id, :bigint
  end
end
