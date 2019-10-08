# frozen_string_literal: true

class AddStripeCustomerIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :stripe_customer_id, :string
  end
end
