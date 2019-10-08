# frozen_string_literal: true

class ActivateAccountAt < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :active_since, :datetime

    change_column_null :organizations, :active_since, false
  end
end
