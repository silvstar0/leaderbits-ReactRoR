# frozen_string_literal: true

class CreateQuestionTags < ActiveRecord::Migration[5.2]
  def change
    create_table :question_tags do |t|
      t.string :label, null: false
      t.references :question

      t.datetime :created_at, null: false
    end
  end
end
