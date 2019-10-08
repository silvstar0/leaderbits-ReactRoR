# frozen_string_literal: true

class RemoveCustomOrderOfLeaderbits < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :custom_order_of_leaderbits, array: true, default: nil
    remove_column :users, :custom_order_of_leaderbits, array: true, default: nil
    remove_column :leaderbits, :position, :integer
  end
end
