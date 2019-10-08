# frozen_string_literal: true

class RenameSeenWelcomeVideo < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :seen_welcome_video, :seen_welcome_video_for_leaders
  end
end
