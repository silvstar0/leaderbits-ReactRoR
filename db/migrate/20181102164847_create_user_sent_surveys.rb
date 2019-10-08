# frozen_string_literal: true

class CreateUserSentSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.string :type, null: false
      t.string :title, null: false

      t.timestamps
    end

    create_table :questions do |t|
      t.references :survey, index: true
      t.json :params, null: false
      t.integer :position

      t.timestamps
    end

    create_table :answers do |t|
      t.references :user, index: true
      t.references :question, index: true
      t.json :params, null: false

      t.timestamps
    end

    create_table :survey_invitations do |t|
      t.references :user

      t.string :to_email, null: false

      t.datetime :created_at
      t.datetime :survey_completed_at
    end
  end
end
