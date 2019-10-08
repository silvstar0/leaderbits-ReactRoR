# frozen_string_literal: true

class AllowUserToBeOnPersonalizedAlgorithm < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :personalized_leaderbits_algorithm_instead_of_regular_schedule, :boolean, null: true
  end
end
