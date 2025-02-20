# frozen_string_literal: true

class RecreateVotesWithProperVersion < ActiveRecord::Migration[5.2]
  def self.up
    drop_table(:votes) if table_exists?(:votes) # recreating with proper version

    create_table :votes do |t|
      t.references :votable, polymorphic: true
      t.references :voter, polymorphic: true

      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight

      t.timestamps
    end

    add_index :votes, %i[voter_id voter_type vote_scope]
    add_index :votes, %i[votable_id votable_type vote_scope]
  end

  def self.down
    drop_table :votes
  end
end
