# frozen_string_literal: true

class DeleteRolifyArtefacts < ActiveRecord::Migration[5.2]
  def change
    drop_table :roles
    drop_table :users_roles
  end
end
