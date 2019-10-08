# frozen_string_literal: true

class AnswerCouldBeAnonymous < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :by_user_with_email, :string
  end
end
