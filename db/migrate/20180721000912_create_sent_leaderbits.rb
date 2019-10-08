# frozen_string_literal: true

class CreateSentLeaderbits < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :welcome_email_sent
  end
end
