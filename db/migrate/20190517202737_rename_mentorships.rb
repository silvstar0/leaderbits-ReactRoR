# frozen_string_literal: true

class RenameMentorships < ActiveRecord::Migration[5.2]
  def change
    rename_table :mentorships, :organizational_mentorships
    rename_column :users, :goes_through_mentorship_onboarding_step, :goes_through_organizational_mentorship_onboarding_step
  end
end
