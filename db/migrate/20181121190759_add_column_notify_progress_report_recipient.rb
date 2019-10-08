# frozen_string_literal: true

class AddColumnNotifyProgressReportRecipient < ActiveRecord::Migration[5.2]
  def change
    #add_reference :users, :progress_report_recipients

    #add_foreign_key :preemptive_leaderbits, :users
    add_column :users, :notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks, :bigint
    add_foreign_key :users, :progress_report_recipients, column: :notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks
  end
end
