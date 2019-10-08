# frozen_string_literal: true

class CreateCanCreateNewUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :can_create_new_users, :boolean, null: false, default: true
  end
end
