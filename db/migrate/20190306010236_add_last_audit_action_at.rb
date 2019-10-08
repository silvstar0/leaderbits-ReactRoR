# frozen_string_literal: true

class AddLastAuditActionAt < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_seen_audit_created_at, :datetime
  end
end
