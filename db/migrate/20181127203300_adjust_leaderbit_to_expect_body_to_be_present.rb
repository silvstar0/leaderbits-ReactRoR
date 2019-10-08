# frozen_string_literal: true

class AdjustLeaderbitToExpectBodyToBePresent < ActiveRecord::Migration[5.2]
  def change
    change_column_null :leaderbits, :body, false
    change_column_null :leaderbits, :user_action_title_suffix, false

    change_column_null :anonymous_survey_participants, :name, false

    change_column_null :leaderbits, :name, false
    change_column_null :leaderbits, :desc, false
    change_column_null :leaderbits, :body, false
    change_column_null :leaderbits, :url, false

    change_column_null :entries, :visibility, false
    change_column_null :users, :default_entry_visibility, false

    change_column_null :organizations, :name, false

    change_column_null :points, :pointable_type, false
    change_column_null :points, :pointable_id, false
  end
end
