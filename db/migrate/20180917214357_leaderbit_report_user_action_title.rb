# frozen_string_literal: true

class LeaderbitReportUserActionTitle < ActiveRecord::Migration[5.2]
  def change
    add_column :leaderbits, :user_action_title_suffix, :string
  end
end
