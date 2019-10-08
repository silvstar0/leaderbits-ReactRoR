# frozen_string_literal: true

class AddWelcomeVideoToUsers < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_column :users, :seen_welcome_video, :boolean, default: false
      end

      dir.down do
        remove_column(:users, :seen_welcome_video) if column_exists?(:users, :seen_welcome_video)
        remove_column(:users, :welcome_video) if column_exists?(:users, :welcome_video)
      end
    end
  end
end
