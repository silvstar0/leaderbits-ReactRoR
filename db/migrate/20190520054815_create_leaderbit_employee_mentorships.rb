# frozen_string_literal: true

class CreateLeaderbitEmployeeMentorships < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderbit_employee_mentorships do |t|
      t.references :mentor_user
      t.references :mentee_user

      t.datetime :created_at
    end

    add_foreign_key :leaderbit_employee_mentorships, :users, column: :mentor_user_id
    add_foreign_key :leaderbit_employee_mentorships, :users, column: :mentee_user_id
  end
end
