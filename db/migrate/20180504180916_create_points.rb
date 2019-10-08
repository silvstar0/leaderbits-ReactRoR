# frozen_string_literal: true

class CreatePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :points do |t|
      t.belongs_to :user, foreign_key: true
      t.integer :value
      t.text :debug_reason
      t.string :pointable_type
      t.integer :pointable_id

      t.timestamps
    end
  end
end
