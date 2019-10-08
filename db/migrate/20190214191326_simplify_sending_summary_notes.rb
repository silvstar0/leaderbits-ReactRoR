# frozen_string_literal: true

class SimplifySendingSummaryNotes < ActiveRecord::Migration[5.2]
  def change
    remove_column :hourly_leaderbit_sending_summaries, :notes
  end
end
