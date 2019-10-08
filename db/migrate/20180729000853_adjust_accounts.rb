# frozen_string_literal: true

class AdjustAccounts < ActiveRecord::Migration[5.2]
  def change
    rename_table :accounts, :organizations

    rename_column :users, :account_id, :organization_id
  end
end
