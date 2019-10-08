# frozen_string_literal: true

class RemoveColumnByUserWithEmail < ActiveRecord::Migration[5.2]
  def change
    remove_column :answers, :by_user_with_email
  end
end
