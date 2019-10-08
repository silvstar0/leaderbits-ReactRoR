# frozen_string_literal: true

class AdjustColumnTypeForUsersCreatedByUser < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :created_by_user_id, true
    change_column :users, :created_by_user_id, 'integer USING NULL'
  end
end
