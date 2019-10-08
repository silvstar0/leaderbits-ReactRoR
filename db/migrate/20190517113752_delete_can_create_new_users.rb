# frozen_string_literal: true

class DeleteCanCreateNewUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :can_create_new_users if column_exists?(:organizations, :can_create_new_users)
  end
end
