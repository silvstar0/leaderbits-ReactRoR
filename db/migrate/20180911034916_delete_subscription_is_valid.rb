# frozen_string_literal: true

class DeleteSubscriptionIsValid < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :subscription_is_valid
  end
end
