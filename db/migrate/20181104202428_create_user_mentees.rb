# frozen_string_literal: true

class CreateUserMentees < ActiveRecord::Migration[5.2]
  def change
    create_table :user_mentees do |t|
      t.references :mentor_user
      t.references :mentee_user

      t.datetime :created_at
    end

    add_foreign_key :user_mentees, :users, column: :mentor_user_id
    add_foreign_key :user_mentees, :users, column: :mentee_user_id
  end
end
