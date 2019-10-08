# frozen_string_literal: true

if defined?(Rack::Timeout)
  # insert middleware wherever you want in the stack, optionally pass
  # initialization arguments, or use environment variables
  # see https://github.com/heroku/rack-timeout#configuring
  #
  # @see ENV['RACK_TIMEOUT_SERVICE_TIMEOUT']
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout
end
