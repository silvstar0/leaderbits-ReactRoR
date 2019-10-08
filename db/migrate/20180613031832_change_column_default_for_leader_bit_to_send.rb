# frozen_string_literal: true

class ChangeColumnDefaultForLeaderBitToSend < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :leaderbit_to_send, from: nil, to: 1
  end
end
