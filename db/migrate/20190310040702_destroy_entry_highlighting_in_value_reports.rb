# frozen_string_literal: true

class DestroyEntryHighlightingInValueReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :entries, :highlighted_in_value_report
  end
end
