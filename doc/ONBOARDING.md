The process
------------
Whenever we have a new client/account/organization, they provide us a list of their users and their roles and associations. This varies greatly from organization to organization. Some want to have teams created upfront, some do not. Some have mentors/mentees list, some do not. Onboarding steps are also very different for each organization and its users(see *_onboarding_step attributes).

If the provided list is not long(~10 records) then account manager(Allison, Fabiana) adds them in the system manually(via admin UI). Otherwise it is done in code using a simple script.

Keep in mind that such lists are usually rather inconsistent(duplicate emails, emails in a different format - not always lower case). That’s why you should try that script locally first before it is executed in production.

There is also a high chance that some of those emails are invalid and would be bounced back by Postmark - in this case Allison or Fabiana will contact the account representative and decide what we should do with those emails and how to update/restart them.

New  account imports:
------------

**1st way** - version controlled scripts(part of db migration or manually executed scripts from console):

The most recent similar migration was found in git history, take a look at 929af33202b7c25278d03795149e8156c7564f34 for example.

Then he adjusted it for the specific client, tested locally, executed in production and deleted this(already) unnecessary migration/import script. You may do it differently, but for Nick that was pretty handy to copy the provided table from Google Spreadsheets, paste it right migration file and parse.

**2nd way** - write a local script, and thoroughly test it.
When it is ready to be executed in production do the following command:

```
cat some_script.rb | heroku run console --app=leaderbits-production --no-tty
```

This way saves you from another deploy(and some downtime). Regardless of the chosen way scripts/migrations should be version controlled.
