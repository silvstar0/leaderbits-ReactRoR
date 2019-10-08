# frozen_string_literal: true

class CreateUserSeenEntryGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_seen_entry_groups do |t|
      t.references :user, index: true
      t.references :entry_group, index: true

      t.datetime :created_at, null: false
    end
  end
end
