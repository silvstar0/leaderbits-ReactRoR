# frozen_string_literal: true

class ExtractVisibilityStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :visibility, :string
    add_column :users, :default_entry_visibility, :string
  end
end
