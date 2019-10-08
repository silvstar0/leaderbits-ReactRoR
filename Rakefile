# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

def rake_puts(*args)
  return if Rails.env.test?

  puts args
end

require 'rake_performance' if ENV['CI']

Rails.application.load_tasks
