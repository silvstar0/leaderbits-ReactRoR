# frozen_string_literal: true

class DeleteGlobalVisibilitySettings < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :default_entry_visibility
  end
end
