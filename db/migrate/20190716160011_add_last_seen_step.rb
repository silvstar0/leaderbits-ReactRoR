# frozen_string_literal: true

class AddLastSeenStep < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_completed_onboarding_step_for_active_recipient, :string

    query = %(COMMENT ON COLUMN users.last_completed_onboarding_step_for_active_recipient IS 'applies only to active recipients, for others there is #first_entry_for_non_active_leaderbits_recipient_user_to_review')
    ActiveRecord::Base.connection.execute(query).values.inspect
  end
end
