# frozen_string_literal: true

class AddRefToParentEntryReply < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :entry_replies, :entry_replies, column: :parent_reply_id
  end
end
