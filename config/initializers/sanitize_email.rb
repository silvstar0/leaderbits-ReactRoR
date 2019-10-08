# frozen_string_literal: true

email_sanitized_to = ENV['EMAIL_SANITIZED_TO']
if defined?(SanitizeEmail) && email_sanitized_to.present?
  SanitizeEmail.force_sanitize = true # by default it is nil
  SanitizeEmail::Config.configure do |config|
    config[:sanitized_to] = email_sanitized_to
    config[:engage] = true
    config[:activation_proc] = proc { Rails.env.staging? }
  end
end
