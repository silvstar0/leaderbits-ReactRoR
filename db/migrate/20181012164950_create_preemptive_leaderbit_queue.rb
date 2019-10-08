# frozen_string_literal: true

class CreatePreemptiveLeaderbitQueue < ActiveRecord::Migration[5.2]
  def change
    create_table :preemptive_leaderbits do |t|
      t.references :leaderbit, index: true
      t.references :user, index: true
      t.integer :position

      t.timestamps
    end
  end
end
