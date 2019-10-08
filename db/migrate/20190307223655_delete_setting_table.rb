# frozen_string_literal: true

class DeleteSettingTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :settings
  end
end
