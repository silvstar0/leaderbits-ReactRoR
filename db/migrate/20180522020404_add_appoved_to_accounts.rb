# frozen_string_literal: true

class AddAppovedToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :approved, :bool, default: false
  end
end
