# frozen_string_literal: true

class PublicColumnIsDeprectatedInRails41 < ActiveRecord::Migration[5.2]
  def change
    rename_column :entries, :public, :is_public
  end
end
