# frozen_string_literal: true

class LeaderbitLogCouldBePrivate < ActiveRecord::Migration[5.2]
  def up
    add_column :entries, :public, :boolean, default: false
  end

  def down
    remove_column :entries, :public if column_exists?(:entries, :public)
    remove_column :leaderbit_logs, :public if column_exists?(:entries, :public)
  end
end
