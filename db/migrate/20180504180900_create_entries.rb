# frozen_string_literal: true

class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.belongs_to :leaderbit, foreign_key: true
      t.text :content
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
