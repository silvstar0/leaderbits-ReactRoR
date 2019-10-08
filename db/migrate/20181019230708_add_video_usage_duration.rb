# frozen_string_literal: true

class AddVideoUsageDuration < ActiveRecord::Migration[5.2]
  def change
    add_column :video_usages, :duration, :integer, null: false
  end
end
