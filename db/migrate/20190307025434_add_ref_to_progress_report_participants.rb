# frozen_string_literal: true

class AddRefToProgressReportParticipants < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :progress_report_recipients, :users, column: :added_by_user_id
  end
end
