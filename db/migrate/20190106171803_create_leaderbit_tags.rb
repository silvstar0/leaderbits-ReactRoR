# frozen_string_literal: true

class CreateLeaderbitTags < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderbit_tags do |t|
      t.string :label, null: false
      t.references :leaderbit

      t.datetime :created_at, null: false
    end
  end
end
