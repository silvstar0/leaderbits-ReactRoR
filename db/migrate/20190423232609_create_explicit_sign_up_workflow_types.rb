# frozen_string_literal: true

class CreateExplicitSignUpWorkflowTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :goes_through_leader_welcome_video_onboarding_step, :boolean
    add_column :users, :goes_through_strengths_360_team_mentorship_onboarding_steps, :boolean

    change_column_null :users, :goes_through_leader_welcome_video_onboarding_step, false
    change_column_null :users, :goes_through_strengths_360_team_mentorship_onboarding_steps, false
  end
end
