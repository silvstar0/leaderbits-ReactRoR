# frozen_string_literal: true

class EntryVisibilityEnforceMigrationConstraints < ActiveRecord::Migration[5.2]
  def change
    remove_column :entries, :is_visible_to_community, :boolean, default: false
    remove_column :users, :new_entry_is_visible_to_community_by_default, default: false
  end
end
