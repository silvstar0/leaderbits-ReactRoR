# frozen_string_literal: true

class CombineFirstAndLastNameFields < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string

    remove_column :users, :full_name_for_search
  end
end
