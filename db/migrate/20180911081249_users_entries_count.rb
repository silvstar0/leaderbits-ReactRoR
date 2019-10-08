# frozen_string_literal: true

class UsersEntriesCount < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :entries_count, :integer, default: 0
  end
end
