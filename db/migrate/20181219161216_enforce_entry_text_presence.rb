# frozen_string_literal: true

class EnforceEntryTextPresence < ActiveRecord::Migration[5.2]
  def change
    change_column_null :entries, :content, false
    rename_column :entry_replies, :text, :content
  end
end
