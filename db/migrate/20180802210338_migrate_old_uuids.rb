# frozen_string_literal: true

class MigrateOldUuids < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :uuid, false
    add_index :users, :uuid, unique: true
  end
end
