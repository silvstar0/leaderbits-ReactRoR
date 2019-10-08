# Configuring LeaderBits
Following the recommendation of [12factor.net](http://12factor.net/config),
LeaderBits takes all of its configuration from environment variables.

In order of precedence LeaderBits uses:
1. Environment variables (for example MY_VALUE=abc bundle exec puma)
2. Values provided in a config/application.yml file

<dl>
<dt>AWS_ACCESS_KEY_ID
<dd>AWS access key ID
<dd>used for activestorage uploads in production
<dt>AWS_BUCKET
<dd>AWS bucket name
<dd>used for activestorage uploads in production, that's the same bucket where Cloudfront gets its data from.
<dt>AWS_REGION
<dd>AWS region
<dd>used for activestorage uploads in production
<dt>AWS_SECRET_ACCESS_KEY
<dd>AWS secret access key
<dd>used for activestorage uploads in production
<dt>BLAZER_DATABASE_URL
<dd>https://github.com/ankane/blazer Blazer business intelligence database URL.
<dd>must be the same as DATABASE_URL
<dt>BUNDLE_GITHUB__COM
<dd>personal oauth token that was previously used for fetching private dependencies.
<dd>
<dt>CLOUDFRONT_HOST
<dd>AWS CLOUDFRONT CDN
<dd>used for activestorage uploads and email assets
<dt>DATABASE_URL
<dd>Database URL
<dd>e.g. "postgres://username:pass@localhost:5432/leader_development"
<dt>INTERCOM_ACCESS_TOKEN
<dd>Intercom credentials setting
<dd>Used for contacts syncing in production
<dt>INTERCOM_APP_ID
<dd>Intercom credentials setting
<dd>Used for contacts syncing in production
<dt>MAPBOX_ACCESS_TOKEN
<dd>MAPBOX access token that is needed by https://github.com/ankane/blazer for displaying pins on a map.
<dd>
<dt>PAPERTRAIL_API_TOKEN
<dd>Papertrail Heroku add-on api token
<dd>Used for log draining
<dt>POSTMARK_API_TOKEN
<dd>
<dd>
<dt>ROLLBAR_ENDPOINT
<dd>Rollbar Heroku add-on setting
<dd>
<dt>ROLLBAR_POST_CLIENT_ITEM
<dd>Rollbar Heroku add-on setting
<dd>Used for Javascript/client-side exception notification
<dt>ROLLBAR_POST_SERVER_ITEM
<dd>Rollbar Heroku add-on setting
<dd>
<dt>SLACK_SUPPORT_ROOM_WEBHOOK_URL
<dd>Slack #leaderbits-support room/channel URL that is used for custom notifications
<dd>
<dt>STRIPE_PUBLISHABLE_KEY
<dd>Stripe credentials key
<dd>used for Stripe Checkout web credit card management interface
<dt>STRIPE_SECRET_KEY
<dd>Stripe credentials key
<dd>used for Stripe Checkout web credit card management interface
<dt>EMAIL_SANITIZED_TO
<dd>
<dd>set it to some email in case you want to catch all outgoing emails on staging and send them to this email instead. Used by sanitize_email gem.
</dl>
