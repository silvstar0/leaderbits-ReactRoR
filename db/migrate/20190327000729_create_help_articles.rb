# frozen_string_literal: true

class CreateHelpArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :help_articles do |t|
      t.string :title, null: false
      t.boolean :visible, null: false, default: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
