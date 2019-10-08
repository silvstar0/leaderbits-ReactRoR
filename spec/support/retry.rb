# frozen_string_literal: true

if defined?(RSpec::Retry)
  require 'rspec/retry'

  exceptions_to_retry = [Net::ReadTimeout]

  RSpec.configure do |config|
    # show retry status in spec process
    config.verbose_retry = true
    # Try twice (retry once)
    config.default_retry_count = 2
    config.exceptions_to_retry = exceptions_to_retry
  end
end
