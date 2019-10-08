# frozen_string_literal: true

class BouncedEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :bounced_emails do |t|
      t.string :email, null: false
      t.text :message
      t.timestamps
    end

    add_index(:bounced_emails, :email, unique: true)
  end
end
