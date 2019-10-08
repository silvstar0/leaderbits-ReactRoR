# frozen_string_literal: true

class UserScheduleIsMandatory < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :users, :schedules, column: :schedule_id, primary_key: 'id'
  end
end
