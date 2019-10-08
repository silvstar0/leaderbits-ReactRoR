# frozen_string_literal: true

class EnforceApiKeyIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :api_key, unique: true
  end
end
