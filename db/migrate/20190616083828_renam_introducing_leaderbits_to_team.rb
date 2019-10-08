# frozen_string_literal: true

class RenamIntroducingLeaderbitsToTeam < ActiveRecord::Migration[5.2]
  def change
    rename_column :organizations, :introducing_leaderbits_to_team, :first_leaderbit_introduction_message
  end
end
