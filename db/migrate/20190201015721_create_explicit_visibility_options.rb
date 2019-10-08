# frozen_string_literal: true

class CreateExplicitVisibilityOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :visible_to_my_mentors, :boolean

    add_column :entries, :visible_to_my_peers, :boolean
    add_column :entries, :visible_to_community_anonymously, :boolean

    remove_column :entries, :visibility
  end
end
