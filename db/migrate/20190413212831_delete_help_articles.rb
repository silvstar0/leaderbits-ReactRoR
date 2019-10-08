# frozen_string_literal: true

class DeleteHelpArticles < ActiveRecord::Migration[5.2]
  def change
    drop_table :help_articles
  end
end
