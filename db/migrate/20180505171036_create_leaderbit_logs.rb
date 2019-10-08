# frozen_string_literal: true

class CreateLeaderbitLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderbit_logs do |t|
      t.belongs_to :leaderbit, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :status
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
