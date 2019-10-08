# frozen_string_literal: true

class SplitCombinedSteps < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :goes_through_strengths_360_team_mentorship_onboarding_steps, :goes_through_mentorship_onboarding_step

    add_column :users, :goes_through_leader_strength_finder_onboarding_step, :boolean
    add_column :users, :goes_through_team_survey_360_onboarding_step, :boolean

    change_column_null :users, :goes_through_leader_strength_finder_onboarding_step, false
    change_column_null :users, :goes_through_team_survey_360_onboarding_step, false
  end
end
