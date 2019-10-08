# frozen_string_literal: true

class AddOrganizationUsersCount < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :users_count, :integer, default: 0
  end
end
