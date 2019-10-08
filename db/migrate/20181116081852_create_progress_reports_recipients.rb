# frozen_string_literal: true

class CreateProgressReportsRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :progress_report_recipients do |t|
      t.string :email, null: false
      t.string :frequency, null: false
      t.references :added_by_user

      t.timestamps
    end
  end
end
