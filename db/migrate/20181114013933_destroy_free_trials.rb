# frozen_string_literal: true

class DestroyFreeTrials < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :free_trial
  end
end
