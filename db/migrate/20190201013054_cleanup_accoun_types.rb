# frozen_string_literal: true

class CleanupAccounTypes < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :intercom_account_type
  end
end
