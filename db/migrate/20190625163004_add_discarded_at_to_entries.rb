# frozen_string_literal: true

class AddDiscardedAtToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :discarded_at, :datetime
    add_index :entries, :discarded_at
  end
end
