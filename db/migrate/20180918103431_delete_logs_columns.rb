# frozen_string_literal: true

class DeleteLogsColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :leaderbit_logs, :started_at, :datetime
    remove_column :leaderbit_logs, :completed_at, :datetime
  end
end
