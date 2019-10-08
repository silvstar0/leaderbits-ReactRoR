# Why two mailer layouts?
Nick: not sure if this should be called technical debt, technically probably yes it should be but it was intentional.
Read this big story to understand the current status of history of recent Email updates https://www.pivotaltracker.com/story/show/167853171
old_mailer was extracted right before emails were partially rolled back to pre-redesign state.
Think of old_mailer layouts as fancy redesign for *admin-only* emails that is close to what Yuri designed.
Ideally all admin mailer templates should have been rewritten as MJML templates as well, but think of priority. Admin mailer recipients are paid to see those emails, they can be asked to open them in modern email clients instead. For long time the design of admin mailer templates were trivial priority.

# Why "Turbograft" instead of "Turbolinks"?

Not really debt, more like explanation:

Turbograft(hard-fork of turbolinks from Shopify) was introduced by Nick as a tradeoff between choosing between Turbolinks & StimulusJS.
The task was to rewrite some of React components which were no longer needed after business requirement changes(and were a bit difficult/messy to test from Capybara).
That's when Nick decided to rewrite new version with updated requirements as a system with regular HAML template & Rails rendering + partial page updates.
Since partial updates were removed from Turbolinks https://stackoverflow.com/questions/36516077/was-partial-replacement-were-removed-in-turbolinks-5 and Nick didn't have much experience of working with Stimulus.js(and time to learn it since it was urgent) Nick decided to use older Turbolinks version with partial updates(Turbograft).

Think of Turbograft not as hard dependency, if for the new redesign you find some other tools better fitting for the job feel free to switch.

# New employee-mentors onboarind is a bit painful at the moment.
When new employee-mentor is added to the system, his/her unread entries counter may easily reach 1K+ which is a bit surprising to users and definitely a bit demotivating. No way you can get to 0 unread counter in a reasonable time.
What's most important is that you as a mentor shouldn't even be replying to those old entries because their authors do not expect replies to them.

How we handle this issue in the past?
We manually marked entries older than t1(1-2-3- weeks) as read.
This happened to Fabiana, Courtney, Allison and recently Jake.

Think about the probability of new employee-mentor appearing, perhaps you should automate it. That's how Nick solved it last time:

```
user = User.find_by_email('jake@moderncto.io')
EntryGroup.where('entry_groups.created_at < ?', 1.week.ago).each do |entry_group|
  UserSeenEntryGroup.find_or_create_by!(user: user, entry_group: entry_group)
end
```

# Papertrail filters/notification rules. What are they for?

Feel free to delete them as we no longer(as of Oct 2019) need them. Those filters was used for some logs/behavior investigation that was completed long time ago and only recently some of those filters fired.

# No ready-made/ActiveAdmin admin interface?

Yes, see https://www.pivotaltracker.com/story/show/168020765 for more info.

# Why progress report recipients are created as "real" uses despite their abilities limited to only watching progress reports and corresponding entries?

That was a trade-off, Nick was choosing between the current of creating them as users(without a schedule/plan) + progress_report_recipient record(1) AND something else which doesn't involve devise user creation(2).

Nick chose (1) as this method seemed to be easier. The main reason for choosing it was that he needed simple_token_authentication links in progress reports email working for those people and simple_token_authentication is very opinionated in what it allows. The alternative solution might involve the creation of a separate Rack middleware.

The drawback of this method is because it looks a bit confusing in admin UI... users that we didn't onboard and client didn't pay for.

But this method became less confusing after we added users#created_by_user_id which is visible in Admin UI.

Aug 30 update by Nick: there is a related story https://www.pivotaltracker.com/story/show/164839457
There wasn'y any clear requirements from Joel on how these emails have to look like so I had to improvise. "See details" link was added but I wasn't 100% sure whether it was a good idea because of the reasons explained in this section.
Theoretically, if we didn't have that "See details" link then we can just send plain text emails and we no longer need to "sign in" those progress report recipients/watchers. Think about the posibility of removing these "See details" links completely or at least for those "technical users"(report recipient role only) - this would simplify the whole setup significantly.

# ActiveStorage configuration on staging
What
------------
You may notice on staging that leaderbit uploads and some others activestorage resources don't look good.
Instead of actual uploads it displays placeholder/dummy images instead.

Why
------------
The reason was that S3 credentials for staging and production are not shared(for security reasons). When db:anonymize rake task is executed against production db dump, it doesn’t treat activestorage uploads properly.

What you can do about it
------------
Adjust db:anonymize script to handle this case?
Fill in all leaderbits and organizations with random uploads instead(on
staging it doesn't matter)?

Protip
------------
Before doing it review S3/Cloudfront credentials.


# Slack webhooks & SMTP accounts
What
------------
SMTP(Postmark) account is shared between staging & production.

1) It makes Postmark sending logs a bit confusing because production emails
are mixed with staging.

2) It makes BOUNCE/SLACK_SUPPORT_ROOM_WEBHOOK_URL notifications to
support channel in slack confusing for the same reason - staging is
mixed with production and it distracts everyone for investigating it
every single time.

You can't fix 2) before credentials are separated.

Referenced link - https://account.postmarkapp.com/servers/3825011/webhooks

Why
------------
Because there was something else urgent to fix and because Joel will
need to be involved in this task.


What you can do about it
------------
Talk to Joel to create a separate postmark account for staging, update
staging ENV variables(postmark & webhook related).
