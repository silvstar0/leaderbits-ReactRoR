# frozen_string_literal: true

class CreateHourlyLeaderbitSendingSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :hourly_leaderbit_sending_summaries do |t|
      t.integer :to_be_sent_quantity, null: true
      t.integer :actual_sent_quantity, null: true
      t.text :notes

      t.timestamps
    end
  end
end
