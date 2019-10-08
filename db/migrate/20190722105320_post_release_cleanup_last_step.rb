# frozen_string_literal: true

class PostReleaseCleanupLastStep < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :seen_welcome_video_for_leaders
  end
end
