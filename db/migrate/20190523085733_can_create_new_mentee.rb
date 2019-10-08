# frozen_string_literal: true

class CanCreateNewMentee < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :can_create_a_mentee, :boolean, default: false
    ActiveRecord::Base.connection.execute("UPDATE users SET can_create_a_mentee = FALSE")
    change_column_null :users, :can_create_a_mentee, false
  end
end
