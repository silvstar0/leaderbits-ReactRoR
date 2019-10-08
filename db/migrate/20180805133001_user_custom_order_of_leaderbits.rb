# frozen_string_literal: true

class UserCustomOrderOfLeaderbits < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :custom_order_of_leaderbits, :integer, array: true, default: nil
  end
end
