Any commit to any branch triggers CircleCI build.

If development branch builds succeds on CircleCi, it triggers the next
step in CircleCI workflow https://github.com/LeaderBits/leader/blob/development/.circleci/config.yml#L170-L180 - deployment of development branch to staging.

If master branch builds succeds on CircleCi, it triggers the next
step in CircleCI workflow https://github.com/LeaderBits/leader/blob/development/.circleci/config.yml#L181-L186 - deployment of master branch to production.

The reasons for doing it automatically rather than manually are:
  * transparency
  * keeping the history of db migration STDOUT verbose logging in case
    it might be needed for investigation.

As team grows this approach would likely to change but it worked really
well until ~Jul 2019 because it allowed really short feedback loop for testing on staging.

Protip
------------
in case a new developer is added to the team, he/she may start with
restricted permission to commit to master branch(Github setting). That's
how you can prevent cases when something incorrect was commited to
master branch which gets automatically released into production.  https://www.pivotaltracker.com/story/show/164413603

All CircleCI system variables are accessible at https://circleci.com/gh/LeaderBits/leader/edit#env-vars as of Jul 2019:


<dl>
<dt>BLAZER_DATABASE_URL
<dd>needed for blazer queries testing
<dt>GITHUB_PERSONAL_ACCESS_TOKEN
<dd>needed for private dependencies local checkout on CircleCI
<dt>HEROKU_API_KEY
<dd>needed for automatic deploys to staging & production - see .circleci/config.yml
<dt>HEROKU_EMAIL
<dd>needed for automatic deploys to staging & production - see .circleci/config.yml
<dt>STRIPE_PUBLISHABLE_KEY
<dd>needed for Stripe widget testing but it was temporary disabled because it wasn't updated for long time and it affects the build time
<dt>STRIPE_SECRET_KEY
<dd>needed for Stripe widget testing
</dl>


2 BUILDPACKS on Heroku for a single app? Why?
----------
Because mjml templates are not precompiled. See https://github.com/sighmon/mjml-rails#deploying-with-heroku for more details.


Jul 01 2019, NOTE for future developer from Nick:
----------
>
>These 3 system variables will need to be updated with new developer's
credentials to ensure CircleCI still does its job with testing and
deploying.
>
>* GITHUB_PERSONAL_ACCESS_TOKEN
>* HEROKU_API_KEY
>* HEROKU_EMAIL
>
> It doesn't need to be urgent though. Ping Nick and tell him that it's
> done or Nick will contact a new developer in 2-3-4 weeks asking if his
> Github & Heroku credentials can be revoked.
> Long story short, these credentials will NOT be revoked suddennly.


In case you have a good reason to deploy manually, that's how Nick did it:
----------

in .git/config:

```
[remote "staging"]
  url = https://git.heroku.com/leaderbits-staging.git
  fetch = +refs/heads/*:refs/remotes/heroku/*
[remote "production"]
  url = https://git.heroku.com/leaderbits.git
  fetch = +refs/heads/*:refs/remotes/heroku/*

$ git push production master
$ git push staging development:master
```

If you decided to deploy manually feel free to add "[ci skip]" to your latest commit so that it doesn't trigger CircleCI build and re-deploys after your manual deploy.


# Production

Backups
----------

```
heroku pg:backups:schedules --app leaderbits
=== Backup Schedules
DATABASE_URL: daily at 14:00 America/Los_Angeles
```

Logs
----------

logs are drained to Papertrail via Heroku add-on.
Papertrail uploads logs to S3 for archiving purposes. That's their User ID specified in ACL for "write objects" permission.
Bucket name is leaderbits-heroku-logs-archive

How to refresh/update anonymized production DB dump(if you have access to Heroku production database):
----------

```
heroku pg:backups:download --app leaderbits
#import it to local db
rake db:anonymize
rake db:dump
#commit updated(db/leader.dump file)
#delete downloaded(non anonymized) dump from local machine to keep it safe
```

Intercom
----------

If format of user data has changed and you want to update all existing users on Intercom execute the following code:

```
puts "\nSyncing all users with Intercom database"

# NOTE: Intercom's limit is approx 80 hits per 10 secs(SyncJob generates
more than just 1 request per user)
multiplier = 15
n = 0
User.all.each_slice(20).to_a.each do |users|
  wait = n * multiplier
  users.each do |user|
    IntercomContactSyncJob.set(wait: wait.seconds).perform_later(user.id)
  end
  n += 1
end
```

It has been extracted(from Heroku after release rake task)
to docs in pursuit of simplification of overall design.
Format changed very rarely so it doesn't make sense to keep
it.
Prior to Mar 08 2019 it was fully functional - in case you
need to restore it sometime in the future.


# Staging

Seed *Staging* database from anonymized production DB dump:
----------

Why we use anonimized production db dump instead of custom seed data script?
To save time maintaining seed data, to make fully functional app on staging and to catch errors sooner. The closer the environment to production the better.

NOTE: even though dump is anonymized you still should treat it as private and periodically review anonymizer script to find ways to improve it and keep always secure.

```
s3cmd put db/leader.dump s3://leaderbits-anonimized-db-dump/
heroku pg:backups:restore $( s3cmd signurl s3://leaderbits-anonimized-db-dump/leader.dump +360 ) DATABASE_URL --app leaderbits-staging
```


# Personal GitHub oauth tokens

Create new personal oauth token with "full control of private repos" permission

https://github.com/settings/tokens/new

To set up your credentials locally, use bundle-config:

```
$ bundle config GITHUB__COM myoauthtoken:x-oauth-basic
```
If you want to apply this configuration only to your current project, do this instead:

```
$ bundle config --local GITHUB__COM myoauthtoken:x-oauth-basic
```

To set your credentials on Heroku, use:

```
heroku config:add BUNDLE_GITHUB__COM=xxxxxxxxxxxxx:x-oauth-basic --app leaderbits-staging
```

