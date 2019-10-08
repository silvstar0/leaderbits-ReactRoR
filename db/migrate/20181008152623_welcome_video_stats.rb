# frozen_string_literal: true

class WelcomeVideoStats < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :welcome_video_seen_seconds, :integer
  end
end
