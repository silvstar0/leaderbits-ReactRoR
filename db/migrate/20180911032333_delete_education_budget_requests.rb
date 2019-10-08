# frozen_string_literal: true

class DeleteEducationBudgetRequests < ActiveRecord::Migration[5.2]
  def change
    drop_table :education_budget_requests
  end
end
