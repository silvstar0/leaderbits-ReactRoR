# frozen_string_literal: true

class TrackVideoUsage < ActiveRecord::Migration[5.2]
  def change
    create_table :video_usages do |t|
      t.string :video_session_id, null: false
      t.integer :seconds_watched, null: false
      t.references :user
      t.references :leaderbit

      t.datetime :created_at
    end
  end
end
