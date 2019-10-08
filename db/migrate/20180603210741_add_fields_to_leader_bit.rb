# frozen_string_literal: true

class AddFieldsToLeaderBit < ActiveRecord::Migration[5.2]
  def change
    add_column :leaderbits, :image, :string, default: 'default.png'
    add_column :leaderbits, :body, :text
    add_column :leaderbits, :active, :bool, default: false
  end
end
