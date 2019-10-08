# frozen_string_literal: true

class ToggleLeaderbitsSendingFlag < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :leaderbits_sending_disabled, :leaderbits_sending_enabled
    change_column_default(:users, :leaderbits_sending_enabled, true)

    rename_column :organizations, :leaderbits_sending_disabled, :leaderbits_sending_enabled
    change_column_default(:organizations, :leaderbits_sending_enabled, true)
  end
end
