# frozen_string_literal: true

class AddUsersDuplicateFullNameForEasyFuzzySearch < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :full_name_for_search, :string, null: false, default: ''
  end
end
