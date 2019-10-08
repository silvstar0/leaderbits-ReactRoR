# frozen_string_literal: true

class UsersProgressSummarySentOnUpdates < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_sent_reports, :updated_at
  end
end
