# [![Application icon](https://leaderbits.io/wp-content/uploads/2019/06/LeaderBits-logo-1.png)][icon]
[icon]: https://app.leaderbits.io

# app.leaderbits.io
[![CircleCI](https://circleci.com/gh/LeaderBits/leader/tree/development.svg?style=svg&circle-token=aec4375c7e1d059d10c3325546539c9d2e5869dc)](https://circleci.com/gh/LeaderBits/leader/tree/development)


# Requirements

The list of requirements to install LeaderBits are:

* Ruby = 2.6.2
* PostgreSQL >= 10
* Redis >= 3.2.12
* pg_restore with recent versions like 10.3, 9.6.8, 9.5.12, 9.4.17, and 9.3.22 or newer. Version is important because older version wouldn't accept Heroku PostgreSQL db dump format.

Installation
------------

*Note*: This app is intended for people with experience deploying and maintaining
Rails applications.

* `git clone git@github.com:LeaderBits/leader.git`
* `bundle install`
* `bundle exec overcommit --install`
* `bundle exec overcommit --sign`
* `bundle exec rails db:create`
* `pg_restore -O -d leader_development db/leader.dump`
* `bundle exec rails db:migrate`
* `yarn install`
* `bundle exec rails server`

Configuration
-------------
LeaderBits configuration is done entirely through environment variables. See
[configuration](doc/CONFIGURATION.md)

Deployment
----------
See [notes on deployment](doc/DEPLOYMENT.md)

New Accounts/Clients onboarding
----------
See [notes on new accounts/clients onboarding](doc/ONBOARDING.md)

Technical debt
----------
See [notes on technical debt](doc/DEBT.md)


Running tests
-------------

Check the [.circleci/config.yml](.circleci/config.yml) file to see how specs are run.
Notice BLAZER_DATABASE_URL ENV variable which you'll need to setup locally in case you want to run all the specs(including blazer-related).

# IMPORTANT

Eager loading
-------------
Avoid putting script files(migrations etc) into /lib folder that has side effects when you load/run it.
This is because config.eager_load is true and lib is in eager_load_paths.
Last thing that you want to do is to run wrong migration in production in the least expected moment.

Postmark
-------------
You may spend quite some time on it unless you worked with Postmark in
the past. It is different in a way that it may overwrite SMTP headers
that you set in your code and set its own Reply-To, for example.

Referenced link - https://account.postmarkapp.com/signature_domains

Copyright
---------

Copyright (c) 2018-2019 LeaderBits
