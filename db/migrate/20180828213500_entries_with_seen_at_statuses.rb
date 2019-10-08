# frozen_string_literal: true

class EntriesWithSeenAtStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :seen_by_system_admin_at, :datetime, null: true
    # it assumes that there is only team leader in any team
    add_column :entries, :seen_by_team_leader_at, :datetime, null: true
  end
end
