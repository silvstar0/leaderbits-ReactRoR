# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :name, null: false, unique: true
      t.references :organization, null: false
      t.timestamps
    end
  end
end
