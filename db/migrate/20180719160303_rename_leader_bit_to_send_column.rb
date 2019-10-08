# frozen_string_literal: true

class RenameLeaderBitToSendColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :leaderbit_to_send, :leaderbit_id_to_send
  end
end
