# frozen_string_literal: true

class AddUuidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uuid, :string, null: true
  end
end
