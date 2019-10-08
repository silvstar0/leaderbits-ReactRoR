# frozen_string_literal: true

class CreateInboundMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :inbound_messages do |t|
      t.json :params, null: false

      t.datetime :created_at
    end
  end
end
