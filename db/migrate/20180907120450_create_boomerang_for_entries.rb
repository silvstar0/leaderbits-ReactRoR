# frozen_string_literal: true

class CreateBoomerangForEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :boomerang_leaderbits do |t|
      t.string :type, null: false

      t.references :user
      t.references :leaderbit
    end
  end
end
