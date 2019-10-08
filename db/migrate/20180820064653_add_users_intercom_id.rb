# frozen_string_literal: true

class AddUsersIntercomId < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :intercom_user_id, :string
  end
end
