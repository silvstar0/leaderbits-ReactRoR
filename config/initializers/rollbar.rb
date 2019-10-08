# frozen_string_literal: true

Rollbar.configure do |config|
  # NOTE: Without configuration, Rollbar is enabled in all environments.
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  else
    config.enabled = true
    config.access_token = ENV.fetch('ROLLBAR_POST_SERVER_ITEM')
    heroku_environment = ENV.keys.grep(/HEROKU/).present?
    if heroku_environment
      # it doesn't exist during precompilation/migration phase so don't delete
      if File.exist?('/etc/heroku/dyno')
        dyno = JSON.parse(`cat /etc/heroku/dyno`)
        #=> {"dyno"=>{"id"=>"eded98bb-ee18-4c14-9403-f9b9280d9c88", "name"=>"run.5774"}, "app"=>{"id"=>"eae50b07-55f1-4a99-9ffc-27bbfc0e48b3", "name"=>"leaderbits-staging"}, "release"=>{"id"=>127, "commit"=>"ed8da663327f11de76e9fadf61a1ccc7764a514a", "description"=>"Deploy ed8da663"}}

        config.code_version = dyno.dig('release', 'commit')
      end
    end

    config.js_enabled = true
    config.js_options = {
      accessToken: ENV.fetch('ROLLBAR_POST_CLIENT_ITEM'),
      captureUncaught: true,
      payload: {
        environment: Rails.env
      }
    }
  end
  #see lib/ext/rails/rollbar.rb
  config.person_username_method = 'rollbar_person_email_method'

  config.person_email_method = 'email'

  # If you want to attach custom data to all exception and message reports,
  # provide a lambda like the following. It should return a hash.
  # config.custom_data_method = lambda { {:some_key => "some_value" } }

  # Add exception class names to the exception_level_filters hash to
  # change the level that exception is reported at. Note that if an exception
  # has already been reported and logged the level will need to be changed
  # via the rollbar interface.
  # Valid levels: 'critical', 'error', 'warning', 'info', 'debug', 'ignore'
  # 'ignore' will cause the exception to not be reported at all.
  # config.exception_level_filters.merge!('MyCriticalException' => 'critical')
  #
  # You can also specify a callable, which will be called with the exception instance.
  # config.exception_level_filters.merge!('MyCriticalException' => lambda { |e| 'critical' })

  config.use_async = true
  config.use_sidekiq 'queue' => 'rollbar'

  # If you run your staging application instance in production environment then
  # you'll want to override the environment reported by `Rails.env` with an
  # environment variable like this: `ROLLBAR_ENV=staging`. This is a recommended
  # setup for Heroku. See:
  # https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment
  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env
end
