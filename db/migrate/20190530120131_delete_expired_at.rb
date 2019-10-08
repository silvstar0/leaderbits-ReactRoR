# frozen_string_literal: true

class DeleteExpiredAt < ActiveRecord::Migration[5.2]
  def change
    remove_column :email_authentication_tokens, :expired_at
  end
end
