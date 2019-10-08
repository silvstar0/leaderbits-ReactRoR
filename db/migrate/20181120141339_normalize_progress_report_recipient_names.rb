# frozen_string_literal: true

class NormalizeProgressReportRecipientNames < ActiveRecord::Migration[5.2]
  def change
    add_column :progress_report_recipients, :name, :string
  end
end
