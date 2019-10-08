# frozen_string_literal: true

class AddCounterCacheToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :users_count, :integer
  end
end
