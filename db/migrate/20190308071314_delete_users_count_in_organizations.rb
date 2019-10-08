# frozen_string_literal: true

class DeleteUsersCountInOrganizations < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :users_count
  end
end
