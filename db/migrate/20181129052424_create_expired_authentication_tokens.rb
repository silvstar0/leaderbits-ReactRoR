# frozen_string_literal: true

class CreateExpiredAuthenticationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :expired_authentication_tokens do |t|
      t.string :authentication_token, limit: 30, null: false, unique: true
      t.references :user, index: true
      t.datetime :created_at
    end
  end
end
