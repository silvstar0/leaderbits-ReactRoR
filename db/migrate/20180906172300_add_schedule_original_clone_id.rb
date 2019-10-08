# frozen_string_literal: true

class AddScheduleOriginalCloneId < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :cloned_from_id, :integer
  end
end
