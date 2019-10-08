# frozen_string_literal: true

if Rails.env.production?
  # because ActionCable+lograge is very buggy and PRs are abandoned for long time
  # fixes #367 NameError: undefined method `append_info_to_payload' for class `ActionCable::Channel::Base'
  # and noisy log
  ActionCable.server.config.logger = Logger.new(nil)
end

Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Compress JavaScripts and CSS.
  # Non-default js_compressor fixes # #40 Uglifier::Error: Unexpected token: name (template). To use ES6 syntax, harmony mode must be enabled with Uglifier.new(:harmony => true).
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :amazon_production
  config.active_storage.service_urls_expire_in = 1.year # default is 5 minutes

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDISTOGO_URL') }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "leader_#{Rails.env}"

  # @see https://github.com/wildbit/postmark-rails#error-handling
  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # do not set it to false because we wouldn't be able to notice undelivered emails.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'app.leaderbits.io' }
  config.action_mailer.asset_host = "https://app.leaderbits.io"
  config.action_mailer.show_previews = true
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)

    # Better log formatting
    config.lograge.enabled = true
    config.lograge.custom_payload do |controller|
      ip =
        begin
          controller.request.remote_ip
        rescue ActionDispatch::RemoteIp::IpSpoofAttackError
          nil
        end

      {
        ip: ip,
        user_id: controller.current_user&.id,
        user_uuid: controller.current_user&.uuid,
        user_email: controller.current_user&.email,
        organization_id: controller.current_user&.organization_id,
        hostname: `hostname`,
        pid: Process.pid
      }
    rescue StandardError => e
      Rollbar.warning(e)

      Rails.logger.warn("Failed to append custom payload: #{e.message}\n#{e.backtrace.join("\n")}")
      {}
    end
    config.lograge.custom_options = lambda do |event|
      exceptions = %w(controller action format id)

      payload_params = event.payload[:params]
      #NOTE: for actioncable payload params could be nil
      params = payload_params ? payload_params.except(*exceptions) : {}
      params[:files].map!(&:headers) if params[:files]

      output = {
        params: params.to_query
      }

      output
    rescue StandardError => e
      Rollbar.warning(e)
      Rails.logger.warn("Failed to append custom options: #{e.message}\n#{e.backtrace.join("\n")}")
      {}
    end
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end

module Rails
  class MailersController
    include Rails.application.routes.url_helpers

    # Override the method just for this controller so `MailersController` thinks
    # all requests are local.
    def local_request?
      true
    end
  end
end
