# frozen_string_literal: true

class AddReferenceToStrengthLevels < ActiveRecord::Migration[5.2]
  def change
    #add_foreign_key :user_strength_levels, :users
    #add_foreign_key :user_sent_reports, :users
    add_foreign_key :user_sent_leaderbits, :users
    add_foreign_key :user_sent_leaderbits, :leaderbits

    add_foreign_key :user_seen_entry_groups, :users
    add_foreign_key :user_seen_entry_groups, :entry_groups
    add_foreign_key :teams, :organizations

    add_foreign_key :replies, :users
    add_foreign_key :replies, :entries

    add_foreign_key :questions, :surveys

    add_foreign_key :preemptive_leaderbits, :leaderbits
    add_foreign_key :preemptive_leaderbits, :users
    add_foreign_key :preemptive_leaderbits, :users, column: :added_by_user_id

    add_foreign_key :momentum_historic_values, :users

    add_foreign_key :leaderbit_schedules, :leaderbits
    #add_foreign_key :leaderbit_schedules, :users

    add_foreign_key :entry_groups, :users
    add_foreign_key :entry_groups, :leaderbits

    add_foreign_key :entries, :entry_groups

    add_foreign_key :boomerang_leaderbits, :users
    add_foreign_key :boomerang_leaderbits, :leaderbits

    add_foreign_key :api_usages, :users

    add_foreign_key :answers, :users
    add_foreign_key :answers, :questions

    add_foreign_key :anonymous_survey_emails, :users, column: :added_by_user_id
  end
end
