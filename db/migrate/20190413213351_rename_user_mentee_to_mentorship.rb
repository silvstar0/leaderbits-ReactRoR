# frozen_string_literal: true

class RenameUserMenteeToMentorship < ActiveRecord::Migration[5.2]
  def change
    rename_table :user_mentees, :mentorships
  end
end
