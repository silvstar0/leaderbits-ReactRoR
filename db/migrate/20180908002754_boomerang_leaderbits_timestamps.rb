# frozen_string_literal: true

class BoomerangLeaderbitsTimestamps < ActiveRecord::Migration[5.2]
  def change
    add_column :boomerang_leaderbits, :created_at, :datetime
    add_column :boomerang_leaderbits, :updated_at, :datetime
  end
end
