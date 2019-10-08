# frozen_string_literal: true

class OrganizationsCustomOrderOfLeaderbits < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :custom_order_of_leaderbits, :integer, array: true, default: nil
  end
end
