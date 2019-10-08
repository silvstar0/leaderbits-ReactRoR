web: bundle exec rails server -p $PORT
worker: bundle exec sidekiq -q default -q mailers -q rollbar
release: bundle exec rake post_release
