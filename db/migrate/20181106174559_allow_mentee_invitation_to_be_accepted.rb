# frozen_string_literal: true

class AllowMenteeInvitationToBeAccepted < ActiveRecord::Migration[5.2]
  def change
    add_column :user_mentees, :accepted_at, :datetime
  end
end
