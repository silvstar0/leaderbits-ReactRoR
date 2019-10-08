# frozen_string_literal: true

class AdjustProgressReportRecipientNameNullConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column_null :progress_report_recipients, :name, from: false, to: true
  end
end
