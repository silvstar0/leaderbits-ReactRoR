# frozen_string_literal: true

class AddJobTitleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :job_level, :string, default: "team_member"
  end
end
