# frozen_string_literal: true

class AddIndexOnHistoricMomentumValues < ActiveRecord::Migration[5.2]
  def change
    add_index :momentum_historic_values, :created_on
  end
end
