# frozen_string_literal: true

class TrackApiUsage < ActiveRecord::Migration[5.2]
  def change
    create_table :api_usages do |t|
      t.json :params, null: false
      t.references :user

      t.datetime :created_at
    end
  end
end
