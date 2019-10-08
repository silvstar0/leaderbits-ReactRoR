# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :c_level, :boolean, null: false, default: false
    add_column :users, :system_admin, :boolean, null: false, default: false

    create_table :team_members do |t|
      t.string :role, null: false, index: true

      t.references :user
      t.references :team

      t.timestamps
    end

    create_table :leaderbits_employees do |t|
      t.references :user
      t.references :organization

      t.timestamps
    end
  end
end
