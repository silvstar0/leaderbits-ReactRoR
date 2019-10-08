# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Only define Ruby version once (i.e. for Heroku)
version_file = File.join(File.dirname(__FILE__), '.ruby-version')
ruby File.read(version_file).strip

source 'https://rails-assets.org' do
  gem 'rails-assets-chartist', '= 0.11.0'
  gem 'rails-assets-jquery', '= 3.3.1'
  gem 'rails-assets-momentjs', '= 2.22.2' # Used by chartist only. Ideally we should get rid of this huge dependency
  gem 'rails-assets-notifyjs', '= 0.4.2'
  gem 'rails-assets-timeago', '= 1.6.3'
end

gem 'acts_as_list', '~> 0.9' # items ordering
gem 'acts_as_votable', '~> 0.12' # entry, answer likes
gem 'addressable' # parsing and manipulating request urls
gem 'audited' # logs all changes to your models
gem 'autoprefixer-rails', '~> 9.4'
gem 'aws-sdk-s3', '~> 1.30', require: false # for ActiveStorage
gem 'blazer' # business intelligence mountable UI framework
gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'breadcrumbs_on_rails', '~> 3.0'
gem 'bundler', '= 2.0.1' # Needed by rails-assets and to just keeping things consistent
gem 'chroma' # color gamma generation
gem 'deep_cloneable' # schedule cloning
gem 'devise', '= 4.6.1' # NOTE: version upgrade would require re-testing of all password/user creation functionality
gem 'discard' # flagging records as discarded/soft-deleted
gem 'draper' #Decorators/View-Models
gem 'dry-transaction' # for complex controller CRUD interactors
gem 'dry-validation' # for complex controller CRUD interactors
gem 'factory_bot_rails'
gem 'faker'
gem 'figaro', '~> 1.1' # Heroku-friendly Rails app configuration using ENV and a single YAML file
gem 'flutie', github: 'kriskhaira/flutie', branch: 'master' # view helpers by thoughtbot for body class & document title. Fork is for :reverse option
gem 'font-awesome-rails', '~> 4.7'
gem 'foundation-rails', '~> 6.5.3.0'
gem 'freshsales'
gem 'friendly_id', '~> 5.2'
gem 'gon' # passing variables from Rails to JS
gem 'high_voltage', '~> 3.1' # engine for static pages
gem 'intercom' # customer support service, low level manual identifying users from backend
gem 'intercom-rails' # customer support service, identifying users from controller actions
gem 'jbuilder', '~> 2.5'
gem 'jquery-ui-rails', '~> 6.0'
gem 'lograge'
gem 'mini_magick', '~> 4.9' # image size conversion by ActiveStorage
gem 'money-rails'
gem 'name_of_person', '~> 1.0' #Presenting names of people in full, familiar, abbreviated, and initialized forms by @dhh
gem 'newrelic_rpm' #performance tracking
gem 'oj', '~> 3.7' # fast JSON parser and Object marshaller. Requested by Rollbar. Not compatible with JRuby
gem 'pg', '~> 1.1' # with postgres.app installed s.add_development_dependency(install pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config
gem 'postmark-rails' # SMTP/mailing
gem 'puma', '~> 4.0' # Use Puma as the app server
gem 'pundit', '~> 2.0'
gem 'rails', '~> 5.2'
gem 'rails_autolink', '~> 1.1' # replies, entries content auto-linking for URLs
gem 'rake-performance' # tracking task duration in Heroku scheduler tasks
gem 'react-rails', '~> 2.5'
gem 'record_tag_helper', '~> 1.0' # "content_tag" support that has been removed from rails core
gem 'rollbar', '~> 2.18' # error alerting & debugging tools
gem 'sass-rails', '~> 5.0'
gem 'sidekiq', '~> 5.2'
gem 'simple_form', '~> 4.0'
gem 'simple_token_authentication', '~> 1.0' # auto-login links from emails
gem 'slack-notifier'
gem 'slim-rails', '~> 3.1'
gem 'stamp', '~> 0.6' # Format dates and times based on human-friendly examples
gem 'stripe'
gem 'switch_user', '~> 1.5' # dropdown in the footer in non-production envs to quickly switch between users
gem 'textacular', '~> 5.0' #exposes full text search capabilities from PostgreSQL
gem 'timecop', '~> 0.9' # used for seeds as well(staging including
gem 'trix-rails', require: 'trix'
gem 'turbograft', '~> 0.4'
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'webpacker', '~> 3.5'
gem 'will_paginate', '~> 3.1'

# Reason why fork is used instead:
# without these updates we can't use unobtrusive flash for all 3 kinds of "flashes"(old/regular, notifyjs flashes/tooltips and *achievement unlocked* splash screens)
# eventually these 2 commits should be sent as pull requests
gem 'unobtrusive_flash', github: 'LeaderBits/unobtrusive_flash', branch: 'multi-format' # takes your controller flash messages and passes them to the frontend via HTTP cookies.

#because Heroku
group :staging, :production do
  gem 'heroku-deflater' # Enable gzip compression on heroku, but don't compress images.
  gem 'rack-timeout'
end

group :development, :test do
  gem 'bullet' #helps to kill N+1 queries and unused eager loading.
  gem 'rails_best_practices'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'scss_lint', require: false #tool for writing clean and consistent SCSS

  if ENV['CI'].nil?
    gem 'byebug' # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    gem 'foreman'
  end
end

group :development, :test, :staging do
  gem 'chronic' # natural language date/time parser
  gem 'database_cleaner'

  if ENV['CI'].nil?
    gem 'pry'
    gem 'sanitize_email' # This gem allows you to override your mail delivery settings, globally or in a local context. It is like a Ruby encrusted condom for your email server
  end
end

group :development do
  gem 'annotate'
  gem 'capybara-email'
  gem 'listen', '>= 3.0.5', '< 3.2' # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'overcommit', require: false # automatic pre-commit checks
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'bundler-audit', require: false
  gem 'poltergeist' # driver for Capybara that allows you to run your tests on a headless WebKit browser, provided by PhantomJS.
  gem 'pundit-matchers'
  gem 'rails-controller-testing' # Brings back `assigns` and `assert_template` to your Rails tests
  gem 'rspec-collection_matchers'
  gem 'rspec-sidekiq'
  gem 'rspec-wait' # wait_for { current_path }.to eq(account_path)
  gem 'selenium-webdriver', '= 3.141.0'
  gem 'shoulda-matchers', '>= 4.0'
  gem 'simplecov', require: false
  gem 'webdrivers'

  if ENV['CI'].nil?
    gem 'launchy' # for poltergeist debugging in browser
  else
    gem 'rspec-instafail' # so that you can instantly see what's failing without waiting for the end of test suite
    gem 'rspec-retry' #first browser spec sometimes fail on CircleCi
    gem 'rspec_junit_formatter' # For CircleCI
  end
end
