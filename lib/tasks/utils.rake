# frozen_string_literal: true

#:nocov:
desc "Truncate database"
task database_cleaner: :environment do
  raise "Not in production" if Rails.env.production?

  DatabaseCleaner.strategy = :truncation # , except: [:any_table_that_you_want_to_skip]
  DatabaseCleaner.clean
  puts "database truncated"
end
#:nocov:
