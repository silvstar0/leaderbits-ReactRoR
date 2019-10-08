# frozen_string_literal: true

class DeleteUsersColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :understand_one
    remove_column :users, :understand_two
    remove_column :users, :understand_three
  end
end
