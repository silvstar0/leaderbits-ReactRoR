# frozen_string_literal: true

class OrganizationLeaderbitsForRealThisTime < ActiveRecord::Migration[5.2]
  def change
    add_column :leaderbits, :organization_id, :integer
  end
end
