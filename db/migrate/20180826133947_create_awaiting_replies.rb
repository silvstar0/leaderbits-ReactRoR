# frozen_string_literal: true

class CreateAwaitingReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.integer :user_id, null: false
      t.integer :entry_id, null: false

      t.text :text, null: false

      t.datetime :sent_at, null: true
      t.timestamps
    end
  end
end
