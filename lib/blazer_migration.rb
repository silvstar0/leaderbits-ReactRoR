# frozen_string_literal: true

# Usage example:
#ActiveRecord::Base.connection.execute(BlazerMigration.new(queries_on_behalf_of_user: User.find_by_email(Rails.configuration.nick_email)).to_sql).values

class BlazerMigration
  def initialize(queries_on_behalf_of_user:)
    @user = queries_on_behalf_of_user

    @http_prefix = case Rails.env
                   when 'development'
                     'http://localhost:3000'
                   when 'test'
                     'http://localhost:3000'
                   when 'staging'
                     'https://leaderbits-staging.herokuapp.com'
                   else
                     'https://app.leaderbits.io'
                   end

    prepare
  end

  def prepare
    @queries = []

    add_query 'Entries Per User', <<-SQL.squish
      SELECT users.email,
             COUNT(*)
      FROM entries
      INNER JOIN users ON entries.user_id = users.id
      GROUP BY 1
    SQL

    add_query 'LeaderBits watch time', <<-SQL.squish
      SELECT date_trunc(''day'', created_at),
             SUM(seconds_watched)
      FROM leaderbit_video_usages
      GROUP BY 1
    SQL

    #IDX
    add_query 'LeaderBits watch time by user', <<-SQL.squish
      SELECT date_trunc(''day'', leaderbit_video_usages.created_at),
             (ROUND(SUM(seconds_watched) / 60.0, 1)) AS minutes
      FROM leaderbit_video_usages
      INNER JOIN users on leaderbit_video_usages.user_id = users.id
      WHERE users.email = {email} GROUP BY 1
    SQL

    #IDY
    add_query 'Momentum by user', <<-SQL.squish
      SELECT momentum_historic_values.created_on,
             momentum_historic_values.value AS momentum
      FROM momentum_historic_values
      INNER JOIN users on momentum_historic_values.user_id = users.id
      WHERE users.email = {email}
      ORDER BY momentum_historic_values.created_on ASC
    SQL

    add_query 'Map', <<-SQL.squish
      SELECT organizations.name as Account,
             users.email,
             ip_address_details.latitude,
             ip_address_details.longitude
      FROM ip_address_details
      INNER JOIN users ON ip_address_details.ip = users.last_sign_in_ip
      INNER JOIN organizations ON users.organization_id = organizations.id
      ORDER BY organization_id
    SQL

    add_query 'Boomerang options', <<-SQL.squish
      SELECT type,
             COUNT(*)
      FROM boomerang_leaderbits
      GROUP BY type
    SQL

    add_query 'Bounced emails', <<-SQL.squish
      SELECT email,
             date_trunc(''day'', created_at) as date
      FROM bounced_emails
      ORDER BY created_at DESC
    SQL

    add_query 'Users',  <<-SQL.squish
        SELECT DISTINCT ON (s) s ts_start, COUNT(users.email) as count
        FROM generate_series(''2018-06-04''::date, current_date, ''1 day'') s
        INNER JOIN users ON users.created_at < s
        GROUP BY 1
    SQL

    add_query 'Mentors', <<-SQL.squish
      SELECT DISTINCT ON (s) s ts_start,
             COUNT(DISTINCT(organizational_mentorships.mentor_user_id)) as count
      FROM generate_series(''2018-11-18''::date, current_date, ''1 day'') s
      INNER JOIN organizational_mentorships ON organizational_mentorships.created_at < s
      GROUP BY 1
    SQL

    add_query 'Mentees', <<-SQL.squish
      SELECT DISTINCT ON (s) s ts_start,
             COUNT(DISTINCT(organizational_mentorships.mentee_user_id)) as count
      FROM
        generate_series(''2018-11-18''::date, current_date, ''1 day'') s
      INNER JOIN organizational_mentorships ON organizational_mentorships.created_at < s
      GROUP BY 1
    SQL

    add_query 'Teams', <<-SQL.squish
      SELECT DISTINCT ON (s) s ts_start,
             COUNT(teams.id) as count
      FROM
        generate_series(''2018-08-03''::date, current_date, ''1 day'') s
      INNER JOIN teams ON teams.created_at < s
      GROUP BY 1
    SQL

    add_query 'Completed anonymous surveys', <<-SQL.squish
      SELECT anonymous_survey_participants.email AS anonymous_email,
             users.email AS on_leader,
             organizations.name,
             CONCAT(''#{@http_prefix}/profile/team-survey-360?user_id='', anonymous_survey_participants.added_by_user_id) AS preview_url,
             answers.created_at::date as voted_on_date
      FROM answers
      INNER JOIN anonymous_survey_participants ON anonymous_survey_participants.id = answers.anonymous_survey_participant_id
      INNER JOIN users ON anonymous_survey_participants.added_by_user_id = users.id
      INNER JOIN organizations ON users.organization_id = organizations.id
      GROUP BY anonymous_survey_participants.email, users.email, preview_url, organizations.name, voted_on_date
      ORDER BY voted_on_date DESC
    SQL

    add_query 'Anonymous survey participant types', <<-SQL.squish
      SELECT sum(case when role = ''direct_report'' then 1 else 0 end) as DirectReport_Count,
             sum(case when role = ''leader-or-mentor'' then 1 else 0 end) as LeadersOrMentors_Count,
             sum(case when role = ''peer'' then 1 else 0 end) as Peer_Count,
             sum(case when role = ''other'' then 1 else 0 end) as Other_Count
      FROM anonymous_survey_participants
    SQL

    #TODO use specific timezone instead?
    #SELECT date_trunc('day', created_at AT TIME ZONE 'Europe/Kiev'), to_be_sent_quantity,
    add_query 'LeaderBits sending schedule', <<-SQL.squish
      SELECT date_trunc(''day'', created_at),
             to_be_sent_quantity,
             actual_sent_quantity
      FROM hourly_leaderbit_sending_summaries
      WHERE created_at > date_trunc(''month'', CURRENT_TIMESTAMP - interval ''2 week'') AND to_be_sent_quantity != 0
      ORDER BY created_at ASC
    SQL

    #TODO get rid of question_id magic constants
    add_query 'All Answers to *List 3 ways %{name} could improve.*', <<-SQL.squish
      SELECT answers.params->''value'' AS List3WaysLeaderCanImprove,
             answers.created_at
      FROM answers
      WHERE answers.question_id IN(17, 45, 62)
    SQL

    #IDZ
    add_query 'Answers to *List 3 ways %{name} could improve.* for specific user', <<-SQL.squish
      SELECT answers.anonymous_survey_participant_id,
             answers.params->''value'' AS ListWaysLeaderCanImprove,
             answers.created_at
      FROM answers
      WHERE question_id IN(17, 45, 62)
        AND answers.anonymous_survey_participant_id IN(SELECT id FROM anonymous_survey_participants WHERE added_by_user_id IN(SELECT id FROM users WHERE email = {email}))
    SQL

    add_query 'Employee mentorship stats', <<-SQL.squish
      SELECT users.name AS name,
             COUNT(*) AS Mentees_Count
      FROM leaderbit_employee_mentorships
      INNER JOIN users ON leaderbit_employee_mentorships.mentor_user_id = users.id
      GROUP BY mentor_user_id, users.name
    SQL

    add_query 'User Action Report Title Suffixes', <<-SQL.squish
      SELECT user_action_title_suffix,
             name
      FROM leaderbits
      WHERE active = TRUE
      ORDER BY id DESC
    SQL

    #TODO get rid of survey_id=1 magic constant
    add_query 'Users with completed Strength Finder survey', <<-SQL.squish
      SELECT users.email,
             CONCAT(''#{@http_prefix}/admin/users/'', users.uuid) AS url,
             users.name AS name,
             organizations.name AS Account
      FROM users
      INNER JOIN organizations ON users.organization_id = organizations.id
      WHERE users.id IN(SELECT user_id FROM answers WHERE question_id IN(SELECT id FROM questions WHERE survey_id = 1))
    SQL

    add_query 'Users with filled in Strength Levels(in dashboard)', <<-SQL.squish
      SELECT DISTINCT users.email,
             users.name AS name,
             organizations.name as Account,
             CONCAT(''#{@http_prefix}/settings/strength_levels?preview_user_id='', users.id) AS preview_url
      FROM users
      INNER JOIN user_strength_levels ON users.id = user_strength_levels.user_id
      INNER JOIN organizations ON users.organization_id = organizations.id
    SQL

    add_query 'Sent emails', <<-SQL.squish
      SELECT DISTINCT ON (s) s ts_start,
             user_sent_emails.type,
             COUNT(user_sent_emails.*) as count
      FROM generate_series(''2018-12-14''::date, current_date, ''1 day'') s
      INNER JOIN user_sent_emails ON user_sent_emails.created_at > s AND user_sent_emails.created_at < s + INTERVAL ''1 DAY''
      GROUP BY 1, 2
    SQL

    add_query 'Vacation Modes', <<-SQL.squish
      SELECT reason,
             vacation_modes.starts_at,
             vacation_modes.ends_at,
             users.name,
             organizations.name
      FROM vacation_modes
      JOIN users ON vacation_modes.user_id = users.id
      JOIN organizations ON users.organization_id = organizations.id
      ORDER BY vacation_modes.ends_at DESC
    SQL
  end

  def add_query(title, sql)
    @queries << [title, sql]
  end

  def to_sql
    #NOTE: it is important NOT to delete queries of other users, as of Jun 2019 has its own queries
    "DELETE FROM blazer_queries WHERE creator_id = #{@user.id};".yield_self do |sql|
      @queries.each do |title, query|
        sql += "INSERT INTO blazer_queries (creator_id, name, description, statement, data_source, created_at, updated_at) VALUES (#{@user.id}, '#{title}', '', '#{query}', 'main', '2019-02-12 07:36:35.970804', '2019-02-12 07:44:16.006625');"
      end

      sql + "SELECT setval('blazer_queries_id_seq', COALESCE((SELECT MAX(id)+1 FROM blazer_queries), 1), false);"
    end
  end
end
