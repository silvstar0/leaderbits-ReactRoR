# frozen_string_literal: true

class UsersProgressSummarySentOn < ActiveRecord::Migration[5.2]
  def change
    create_table :user_sent_reports do |t|
      t.string :type, null: false, index: true
      #t.integer :user_id, null: false, index: true

      t.timestamps
    end

    add_reference :user_sent_reports, :user, foreign_key: true, index: true, null: true
    add_index :user_sent_reports, %i[type user_id]
  end
end
