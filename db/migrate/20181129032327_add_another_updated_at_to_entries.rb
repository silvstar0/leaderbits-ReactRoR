# frozen_string_literal: true

class AddAnotherUpdatedAtToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :content_updated_at, :datetime
  end
end
