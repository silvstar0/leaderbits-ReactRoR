# frozen_string_literal: true

class DisableLeaderbitsSending < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :leaderbits_sending_disabled, :boolean, default: false
    add_column :users, :leaderbits_sending_disabled, :boolean, default: false
  end
end
