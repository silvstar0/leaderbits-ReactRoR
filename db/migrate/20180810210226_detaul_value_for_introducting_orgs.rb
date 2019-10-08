# frozen_string_literal: true

class DetaulValueForIntroductingOrgs < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:organizations, :introducing_leaderbits_to_team, nil)
  end
end
