# frozen_string_literal: true

class RenameForTryingToHide < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :notify_my_observers_if_i_remove_them_from_list, :notify_observer_if_im_trying_to_hide
  end
end
