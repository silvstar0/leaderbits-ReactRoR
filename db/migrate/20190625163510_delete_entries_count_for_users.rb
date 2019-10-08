# frozen_string_literal: true

class DeleteEntriesCountForUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :entries_count
  end
end
