# frozen_string_literal: true

class AddUserHideNotificationOption < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notify_users_if_i_remove_them_from_slacking_off_list, :boolean, default: false
  end
end
