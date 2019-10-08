# frozen_string_literal: true

#:nocov:
class IntercomData
  CUSTOM_ATTRIBUTES = %i[
    admin_page
    company_account_type
    completed_leaderbits_count
    last_challenge_completed
    momentum
    points
    schedule_type
    time_zone
    upcoming_challenge
    uuid
  ].freeze

  def initialize(existing_intercom_data:, user:)
    @existing_intercom_data = existing_intercom_data
    @user = user

    if @user.intercom_user_id != @existing_intercom_data.id
      @user.intercom_user_id = @existing_intercom_data.id
      @user.save!
    end
  end

  def override_with_local_data
    data_in_our_db = @user.intercom_custom_data

    @changed = false

    if @existing_intercom_data.name != @user.name
      @existing_intercom_data.name = @user.name
      @changed = true
    end

    CUSTOM_ATTRIBUTES.each do |attr|
      value = @existing_intercom_data.custom_attributes.fetch(attr, nil)
      if value.nil? || value != data_in_our_db.fetch(attr.dup.to_sym)
        @existing_intercom_data.custom_attributes[attr] = data_in_our_db.fetch(attr.dup.to_sym)
        @changed = true
      end
    end

    @existing_intercom_data.companies = [{ id: @user.organization_id, name: @user.organization.name }]

    @new_intercom_data = @existing_intercom_data

    self
  end

  def new_intercom_data
    @new_intercom_data || raise
  end

  def changed?
    @changed == true
  end
end
#:nocov:
