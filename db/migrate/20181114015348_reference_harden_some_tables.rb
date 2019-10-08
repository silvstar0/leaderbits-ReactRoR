# frozen_string_literal: true

class ReferenceHardenSomeTables < ActiveRecord::Migration[5.2]
  def change
    #add_foreign_key :user_mentees, :users, column: :mentor_user_id
    add_foreign_key :video_usages, :users
    add_foreign_key :video_usages, :leaderbits
  end
end
