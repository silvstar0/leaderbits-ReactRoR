# frozen_string_literal: true

class HighlightEntryInReport < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :highlighted_in_value_report, :boolean, default: false
  end
end
