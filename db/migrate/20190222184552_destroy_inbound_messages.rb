# frozen_string_literal: true

class DestroyInboundMessages < ActiveRecord::Migration[5.2]
  def change
    drop_table :inbound_messages
  end
end
