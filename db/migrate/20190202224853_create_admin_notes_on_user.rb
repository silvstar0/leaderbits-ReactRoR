# frozen_string_literal: true

class CreateAdminNotesOnUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin_notes, :text
  end
end
