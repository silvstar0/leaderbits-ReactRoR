# frozen_string_literal: true

class CreateStrengthLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :user_strength_levels do |t|
      t.string :symbol_name
      t.references :user, foreign_key: true, null: false
      t.integer :value
    end
  end
end
