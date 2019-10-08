# frozen_string_literal: true

class AddCountReverseFlagToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :count_as_reverse, :boolean, default: false
  end
end
