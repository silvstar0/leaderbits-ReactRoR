# frozen_string_literal: true

class AdjustSendingDisabledNullValue < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :leaderbits_sending_disabled, false
    change_column_null :organizations, :leaderbits_sending_disabled, false
  end
end
