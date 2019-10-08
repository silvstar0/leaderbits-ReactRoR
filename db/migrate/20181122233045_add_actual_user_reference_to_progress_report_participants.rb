# frozen_string_literal: true

class AddActualUserReferenceToProgressReportParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :progress_report_recipients, :user_id, :bigint
    add_foreign_key :progress_report_recipients, :users
  end
end
