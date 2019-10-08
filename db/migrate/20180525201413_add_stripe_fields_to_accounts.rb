# frozen_string_literal: true

class AddStripeFieldsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :free_trial, :boolean, default: true, null: false
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :stripe_subscription_id, :string
    add_column :accounts, :subscription_is_valid, :boolean, default: true, null: false
  end
end
