# frozen_string_literal: true

class CreateLeaderbits < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderbits do |t|
      t.string :name
      t.text :desc
      t.string :url

      t.timestamps
    end
  end
end
