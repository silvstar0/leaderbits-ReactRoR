**Aud 2019, Nick:**

that doc was requested by Joel to be created. It looks like one-time "report" that he needed to share with someone. If this report is not requested for long time feel free to just delete this doc.

---

user_ids = User.active_recipient.collect(&:id)

since_at = Date.parse('May 01 2019')

total_challenges_received = UserSentScheduledNewLeaderbit.where('created_at > ?, since_at).where(user_id: user_ids).count

total_challenges_seen = LeaderbitVideoUsage.where('created_at > ?', since_at).where(user_id: user_ids).group_by { |lvu| { lvu.user_id => lvu.leaderbit_id } }.collect { |k, v| { k => v.collect(&:duration).sum } }.count

completed_challenges = LeaderbitLog.where('updated_at > ?', since_at).where(status: 'completed', user_id: user_ids).count
completion_rate = completed_challenges / totaL_challenges_seen.to_f
￼
# Quarter to date
start_at = Time.now.beginning_of_quarter
highly_active_users = User.active_recipient.select { |user| user.activity_type(start_at, Time.now) == :highly_active }.count
active_users = User.active_recipient.select { |user| user.activity_type(start_at, Time.now) == :active }.count
not_active_users = User.active_recipient.select { |user| user.activity_type(start_at, Time.now) == :not_active }.count
