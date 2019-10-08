# frozen_string_literal: true

class RenameVideoUsages < ActiveRecord::Migration[5.2]
  def change
    rename_table :video_usages, :leaderbit_video_usages
  end
end
