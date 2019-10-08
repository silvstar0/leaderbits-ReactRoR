# frozen_string_literal: true

class CreatePauseReason < ActiveRecord::Migration[5.2]
  def change
    create_table :vacation_modes do |t|
      t.references :user
      t.text :reason

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end
  end
end
