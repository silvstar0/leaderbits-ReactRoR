# frozen_string_literal: true

class DropAccountsApprovedFlag < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :approved, :boolean, default: true
  end
end
