# frozen_string_literal: true

class AddNotifyMePersonalCheckbox < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notify_me_if_i_missing_2_weeks_in_a_row, :boolean, default: true
  end
end
