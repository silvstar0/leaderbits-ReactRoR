# frozen_string_literal: true

class RenameDebugReasons < ActiveRecord::Migration[5.2]
  def change
    rename_column :points, :debug_reason, :type
  end
end
