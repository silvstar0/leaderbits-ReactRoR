# frozen_string_literal: true

class AddLeaderbitTagRef < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :leaderbit_tags, :leaderbits
    add_foreign_key :question_tags, :questions

    add_index :progress_report_recipients, :user_id
    add_index :preemptive_leaderbits, :added_by_user_id
  end
end
