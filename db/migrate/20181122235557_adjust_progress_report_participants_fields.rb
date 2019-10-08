# frozen_string_literal: true

class AdjustProgressReportParticipantsFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :progress_report_recipients, :name
    remove_column :progress_report_recipients, :email
  end
end
