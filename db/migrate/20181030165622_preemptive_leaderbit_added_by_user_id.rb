# frozen_string_literal: true

class PreemptiveLeaderbitAddedByUserId < ActiveRecord::Migration[5.2]
  def change
    add_column :preemptive_leaderbits, :added_by_user_id, :integer
  end
end
