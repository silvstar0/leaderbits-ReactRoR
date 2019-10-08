# frozen_string_literal: true

class RecreateEntryGroups < ActiveRecord::Migration[5.2]
  def change
    drop_table(:user_seen_entries)
  end
end
