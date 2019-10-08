# frozen_string_literal: true

class CleanupJobLevels < ActiveRecord::Migration[5.2]
  def change
    # with new role system we don't need it. User's job level is its role(or highest role)
    remove_column :users, :job_level, :string, default: 'team_member'
  end
end
