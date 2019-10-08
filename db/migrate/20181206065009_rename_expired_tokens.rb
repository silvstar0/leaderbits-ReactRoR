# frozen_string_literal: true

class RenameExpiredTokens < ActiveRecord::Migration[5.2]
  def change
    rename_table :expired_authentication_tokens, :email_authentication_tokens

    add_column :email_authentication_tokens, :valid_until, :datetime
    add_column :email_authentication_tokens, :expired_at, :datetime
  end
end
