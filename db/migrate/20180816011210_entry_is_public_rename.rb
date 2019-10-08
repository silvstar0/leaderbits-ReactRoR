# frozen_string_literal: true

class EntryIsPublicRename < ActiveRecord::Migration[5.2]
  def change
    rename_column :entries, :is_public, :is_visible_to_community
    rename_column :users, :new_entry_is_public_by_default, :new_entry_is_visible_to_community_by_default
  end
end
