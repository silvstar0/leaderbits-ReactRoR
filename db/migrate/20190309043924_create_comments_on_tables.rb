# frozen_string_literal: true

class CreateCommentsOnTables < ActiveRecord::Migration[5.2]
  def change
    query = %(COMMENT ON TABLE answers IS 'Answers by users to survey questions')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN answers.user_id IS 'Present in case that is leader-user answering Survey::Types::FOR_LEADER question')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN answers.by_user_with_email IS 'Present in case that is anonymous user answering Survey::Types::FOR_FOLLOWER survey question about his leader')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE anonymous_survey_completed_sessions IS 'needed to logically group together *anonymous survey sessions* because surveying could be periodic/ongoing')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON COLUMN anonymous_survey_participants.uuid IS 'needed because we can identify anon user only by this field as GET param accessed from sent email where we requested to participate in survey')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN anonymous_survey_participants.added_by_user_id IS 'leader-user who requested (email; name) to participate in anonymous survey')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE api_usages IS 'logging all user initiated API requests, preparating for future rate limiting/logging')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE boomerang_leaderbits IS 'way for user to be reminded about his own entry(entries) in the future and probably retake the challenge')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE bounced_emails IS 'users with such emails are excluded from sending emails - sometimes we are provided with invalid emails or they become invalid over time')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE email_authentication_tokens IS 'needed so that simple_token_authentication auto-login links dont last longer than 3 weeks')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE entry_groups IS 'needed because leaders may post several entries by leaderbit and we need to display them as group and mark them as read as a group')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE entry_replies IS 'replies to entries by system-admin/Joel, mentors, employees and replies to entry_replies')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE ip_address_details IS 'Used for displaying users on map(mapbox) in the Blazer query')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE leaderbit_video_usages IS 'used for tracking total leaderbit video watch time by user because Vimeo does not give us such info. Needed because same video could be seen multiple times and we need to know how it changes overtime')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN leaderbit_video_usages.video_session_id IS 'uniq identifier that is generated per page view. In periodic AJAX requests we are incrementing #seconds_watched by providing this identifier.')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE momentum_historic_values IS 'user for tracking how users momentum is changing over time. Important metric that is used in many graphs')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE organizations IS 'Joel and team is more used to term *Account* but technically organization is more descriptive')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE question_tags IS 'used for labeling survey questions. Needed for matching them to leaderbit tags which is needed for future more intelligent leaderbit scheduling algorithms')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE leaderbit_tags IS 'used for labeling leaderbits. Needed for matching them to survey question tags which is needed for future more intelligent leaderbit scheduling algorithms')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE questions IS 'survey questions - contains both types leadership surveying and anonymous survey on how you view your leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE surveys IS 'contains both types - leadership surveying and anonymous survey on how you view your leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE teams IS 'teams within organization. Originally was needed because there was special roles - team leader, leader of team leaders, team member. upd. Not sure if we still need it')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE user_seen_entry_groups IS 'needed for tracking entry group *Seen*/*Mark as Read* status')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE user_sent_emails IS 'STI table where we store all emails that we sent to each user. Needed for transparency and tracking last-time-sent-at for periodic email reports - e.g. monthly')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON COLUMN entries.content_updated_at IS 'needed to reliably separate actual content update time from nested :touch => true ActiveRecord triggers')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE leaderbit_logs IS 'stores in which statuses leaderbits are for user - started, completed etc')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON COLUMN organizations.active_since IS 'needed in cases when organization is created prematurely but it must be activated on certain date')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE points IS 'points given to user for certain actions - needed for leveling him up over time and displaying additional features')
    ActiveRecord::Base.connection.execute(query).values.inspect


    query = %(COMMENT ON TABLE preemptive_leaderbits IS 'separate leaderbit schedule that puts users default schedule on pause until whole preemptive leaderbit queue is sent')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.last_seen_audit_created_at IS 'needed for properly counting unseen new audit logs in Admin interface')
    ActiveRecord::Base.connection.execute(query).values.inspect
  end
end
