# frozen_string_literal: true

class AdjustPointsSchema < ActiveRecord::Migration[5.2]
  def change
    change_column :points, :type, :string, null: false
    change_column :points, :value, :integer, null: false
  end
end
