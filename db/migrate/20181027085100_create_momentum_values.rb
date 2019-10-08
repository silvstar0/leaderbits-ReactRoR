# frozen_string_literal: true

class CreateMomentumValues < ActiveRecord::Migration[5.2]
  def change
    create_table :momentum_historic_values do |t|
      t.references :user
      t.integer :value, null: false
      t.date :created_on, null: false
    end
  end
end
