# frozen_string_literal: true

class RenameReplies < ActiveRecord::Migration[5.2]
  def change
    rename_table :replies, :entry_replies
  end
end
