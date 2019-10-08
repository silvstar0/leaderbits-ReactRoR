# frozen_string_literal: true

class InboundMessageReferenceForEntries < ActiveRecord::Migration[5.2]
  def change
    add_reference :entries, :inbound_message
  end
end
