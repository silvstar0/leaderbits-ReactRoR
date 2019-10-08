# frozen_string_literal: true

class PrefillLeaderbitEntryText < ActiveRecord::Migration[5.2]
  def change
    add_column :leaderbits, :entry_prefilled_text, :text
  end
end
