# frozen_string_literal: true

class DestroyUserSentReports < ActiveRecord::Migration[5.2]
  def change
    drop_table :user_sent_reports
  end
end
