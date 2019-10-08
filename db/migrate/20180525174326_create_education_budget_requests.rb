# frozen_string_literal: true

class CreateEducationBudgetRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :education_budget_requests do |t|
      t.string :company_name
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
