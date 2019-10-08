# frozen_string_literal: true

def skip_intercom_sync?
  return false if Rails.env.test? # needed for specs

  ENV.fetch('INTERCOM_ACCESS_TOKEN', nil).nil?
end

IntercomRails.config do |config|
  # == Intercom app_id
  #
  config.app_id = ENV["INTERCOM_APP_ID"]

  # == Intercom session_duration
  #
  # config.session_duration = 300000
  # == Intercom secret key
  # This is required to enable Identity Verification, you can find it on your Setup
  # guide in the "Identity Verification" step.
  #
  # config.api_secret = "..."

  # == Enabled Environments
  # Which environments is auto inclusion of the Javascript enabled for
  #
  config.enabled_environments = ["production"]

  # == Include for logged out Users
  # If set to true, include the Intercom messenger on all pages, regardless of whether
  # The user model class (set below) is present.
  # config.include_for_logged_out_users = true

  # == Lead/custom attributes for non-signed up users
  # Pass additional attributes to for potential leads or
  # non-signed up users as an an array.
  # Any attribute contained in config.user.lead_attributes can be used
  # as custom attribute in the application.
  config.user.lead_attributes = %w(ref_data utm_source)

  # == Exclude users
  # A Proc that given a user returns true if the user should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  config.user.exclude_if = proc { |user| user.discarded_at.present? || user.schedule_id.blank? }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.
  #
  # config.user.custom_data = {
  #   :plan => Proc.new { |current_user| current_user.plan.name },
  #   :favorite_color => :favorite_color
  # }
  config.user.custom_data = proc { |user| user.intercom_custom_data }

  # == Current company method/variable
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
  # config.company.current = Proc.new { current_company }
  config.company.current = proc { current_user.organization }

  # == Exclude company
  # A Proc that given a company returns true if the company should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.company.exclude_if = Proc.new { |app| app.subdomain == 'demo' }

  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
  # config.company.custom_data = {
  #   :number_of_messages => Proc.new { |app| app.messages.count },
  #   :is_interesting => :is_interesting?
  # }
  config.company.custom_data = proc { |organization| organization.intercom_custom_data }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  # config.company.plan = Proc.new { |current_company| current_company.plan.name }

  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
  # config.company.monthly_spend = Proc.new { |current_company| current_company.plan.price }
  # config.company.monthly_spend = Proc.new { |current_company| (current_company.plan.price - current_company.subscription.discount) }

  # == Custom Style
  # By default, Intercom will add a button that opens the messenger to
  # the page. If you'd like to use your own link to open the messenger,
  # uncomment this line and clicks on any element with id 'Intercom' will
  # open the messenger.
  config.inbox.style = :custom
  #
  # If you'd like to use your own link activator CSS selector
  # uncomment this line and clicks on any element that matches the query will
  # open the messenger
  config.inbox.custom_activator = '.intercom-link'
  #
  # If you'd like to hide default launcher button uncomment this line
  # config.hide_default_launcher = true
end
