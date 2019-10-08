# frozen_string_literal: true

class AddOrganizationIdToLeaderbits < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :first_leaderbit_to_be_sent_during_week_that_starts_on, :date

    create_table :user_sent_leaderbits do |t|
      t.references :user
      t.references :leaderbit

      t.datetime :sent_at, null: false
    end
  end
end
