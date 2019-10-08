# frozen_string_literal: true

class CleanupEntryReplySentAt < ActiveRecord::Migration[5.2]
  def change
    remove_column :entry_replies, :sent_at
  end
end
