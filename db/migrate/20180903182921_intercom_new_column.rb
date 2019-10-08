# frozen_string_literal: true

class IntercomNewColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :intercom_account_type, :string
  end
end
