# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'selenium-webdriver'

Capybara.default_max_wait_time = 4 #default is 2

Capybara.run_server = true
Capybara.app_host = "http://localhost:#{SERVER_PORT_IN_TEST_ENV}"
Capybara.server_host = "localhost"
Capybara.server_port = SERVER_PORT_IN_TEST_ENV

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    #phantomjs_options: ['--load-images=no'],
                                    debug: true) #TODO do we still need to debug it?
  # js_errors: true
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.javascript_driver = if ENV['CI'].present?
                               :headless_chrome
                             else
                               :selenium_chrome
                             end
