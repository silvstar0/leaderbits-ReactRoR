# frozen_string_literal: true

class CreateUserSeenEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :user_seen_entries do |t|
      t.integer :user_id, null: false
      t.integer :entry_id, null: false

      t.datetime :created_at, null: true
    end
    add_index :user_seen_entries, [:user_id]
    add_index :user_seen_entries, %i[user_id entry_id]

    remove_column :entries, :seen_by_system_admin_at, :datetime, null: true
    remove_column :entries, :seen_by_team_leader_at, :datetime, null: true
  end
end
