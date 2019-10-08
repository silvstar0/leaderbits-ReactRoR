# frozen_string_literal: true

class RemoveColumnApi < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :api_key
  end
end
