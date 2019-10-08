# frozen_string_literal: true

class AfterReleaseCleanup < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :role, :string, default: "team_member"
  end
end
