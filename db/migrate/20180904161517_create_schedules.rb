# frozen_string_literal: true

class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.string :name, null: false
    end

    add_column :users, :schedule_id, :integer

    create_table :leaderbit_schedules do |t|
      t.integer :leaderbit_id, null: false
      t.integer :schedule_id, null: false

      t.integer :position
    end

    add_column :organizations, :custom_default_schedule_id, :integer

    add_index :leaderbit_schedules, :leaderbit_id
    add_index :leaderbit_schedules, :schedule_id
  end
end
