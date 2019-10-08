# frozen_string_literal: true

class DeleteApiUsages < ActiveRecord::Migration[5.2]
  def change
    drop_table :api_usages
  end
end
