# frozen_string_literal: true

class CreateParentReplies < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :parent_reply_id, :integer, null: true
  end
end
