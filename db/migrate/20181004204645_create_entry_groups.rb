# frozen_string_literal: true

class CreateEntryGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :entry_groups do |t|
      t.references :leaderbit, index: true
      t.references :user, index: true

      t.timestamps
    end

    add_reference :entries, :entry_group
  end
end
