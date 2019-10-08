# frozen_string_literal: true

#:nocov
class IntercomContactSyncJob < ApplicationJob
  queue_as :default

  #NOTE: it is important to silence all SUE exceptions because otherwise we would quickly hit Rollbar exceptions quota
  # Intercom::ServiceUnavailableError: Sorry, the API service is temporarily unavailable
  rescue_from(Intercom::ServiceUnavailableError) do |e|
    Rails.logger.error "Could not execute #{self.class.name} [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  end

  rescue_from(Intercom::RateLimitExceeded) do |e|
    Rails.logger.error "Could not execute #{self.class.name} [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  end

  def perform(user_id)
    return if Rails.env.test?

    #NOTE perhaps checking whether user is active_recipient here is too restrictive?
    #     think about use case when user has been suspended and this info has to be propagated to Intercom(currently it would not)
    user = User.active_recipient.where(id: user_id).first

    # progress report recipient?
    return if user.blank?

    if skip_intercom_sync?
      raise "missing INTERCOM_ACCESS_TOKEN" if Rails.env.production?

      Rails.logger.info "Skipping IntercomContactSyncJob due to missing INTERCOM_ACCESS_TOKEN"
      return
    end

    begin
      attempt_to_update_existing_intercom_user(user)
    rescue Intercom::ResourceNotFound
      create_new_intercom_user(user)
    rescue Intercom::MultipleMatchingUsersError => e
      Rollbar.scoped(message: e.message, user_id: user_id, email: user.email) do
        Rollbar.warning("Multiple existing users match this email")
      end
    end
  end

  private

  # @param [ActiveRecord::Base] user instance
  def attempt_to_update_existing_intercom_user(user)
    intercom_data = IntercomData.new(existing_intercom_data: intercom_client.users.find(email: user.email),
                                     user: user)
    intercom_data.override_with_local_data
    if intercom_data.changed? # otherwise no changes were made for user. Skipping API call
      # puts "Syncing changed custom attributes #{@intercom_data.new_intercom_data.inspect.to_s[0..80]}"
      intercom_client.users.save(intercom_data.new_intercom_data)
    end
  end

  # @param [ActiveRecord::Base] user instance
  def create_new_intercom_user(user)
    # puts "Creating new user #{intercom_data.inspect.to_s[0..80]}" if Rails.env.development?
    intercom_client.users.create(email: user.email, name: user.name) # , signed_up_at: Time.now.to_i)

    intercom_data = IntercomData.new(existing_intercom_data: intercom_client.users.find(email: user.email),
                                     user: user)
    # NOTE: existing data is blank, just override it without checking
    intercom_data.override_with_local_data

    intercom_client.users.save(intercom_data.new_intercom_data)
  end
end
#:nocov
