# frozen_string_literal: true

class EnsureLeaderbitLogStatusPresence < ActiveRecord::Migration[5.2]
  def change
    change_column_null :leaderbit_logs, :status, false
  end
end
