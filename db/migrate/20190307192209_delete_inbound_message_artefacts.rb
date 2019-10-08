# frozen_string_literal: true

class DeleteInboundMessageArtefacts < ActiveRecord::Migration[5.2]
  def change
    remove_column :entries, :inbound_message_id
  end
end
