# frozen_string_literal: true

class DefaultEntryVisibilityStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :new_entry_is_public_by_default, :boolean, default: false
  end
end
