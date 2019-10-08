# frozen_string_literal: true

class DeleteStripeArtefacts < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :stripe_customer_id
    remove_column :organizations, :stripe_subscription_id
  end
end
