# frozen_string_literal: true

class RenameNewUserField < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :notify_users_if_i_remove_them_from_slacking_off_list, :notify_my_observers_if_i_remove_them_from_list
  end
end
