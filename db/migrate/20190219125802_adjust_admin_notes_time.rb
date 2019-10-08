# frozen_string_literal: true

class AdjustAdminNotesTime < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin_notes_updated_at, :datetime
  end
end
