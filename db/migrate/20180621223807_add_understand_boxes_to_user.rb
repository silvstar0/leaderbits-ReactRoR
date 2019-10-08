# frozen_string_literal: true

class AddUnderstandBoxesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :understand_one, :bool, default: false
    add_column :users, :understand_two, :bool, default: false
    add_column :users, :understand_three, :bool, default: false
  end
end
