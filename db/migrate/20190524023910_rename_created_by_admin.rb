# frozen_string_literal: true

class RenameCreatedByAdmin < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :created_by_admin, :created_by_user_id

    query = %(COMMENT ON COLUMN users.created_by_user_id IS 'needed so that we can distinguish users created by admin/employee from those created by organizational mentors')
    ActiveRecord::Base.connection.execute(query).values.inspect
  end
end
