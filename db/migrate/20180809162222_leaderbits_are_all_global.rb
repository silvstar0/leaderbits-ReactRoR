# frozen_string_literal: true

class LeaderbitsAreAllGlobal < ActiveRecord::Migration[5.2]
  def change
    remove_column :leaderbits, :organization_id, :integer
  end
end
