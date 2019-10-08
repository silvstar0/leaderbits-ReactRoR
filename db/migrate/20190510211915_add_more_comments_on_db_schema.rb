# frozen_string_literal: true

class AddMoreCommentsOnDbSchema < ActiveRecord::Migration[5.2]
  def change
    query = %(COMMENT ON TABLE leaderbits_employees IS 'users in the system who are official LeaderBits Employees - Allison, Fabiana, Courtney etc')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON TABLE progress_report_recipients IS 'manageable from the Accountability page')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.notify_me_if_i_missing_2_weeks_in_a_row IS 'accountability feature')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.notify_observer_if_im_trying_to_hide IS 'accountability feature')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks IS 'accountability feature')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.goes_through_leader_welcome_video_onboarding_step IS '1st step by default for a new leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.goes_through_mentorship_onboarding_step IS '4th step by default for a new leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.goes_through_leader_strength_finder_onboarding_step IS '2nd step by default for a new leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.goes_through_team_survey_360_onboarding_step IS '3rd step by default for a new leader')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.system_admin IS 'highest role in the system - Joel, Fabiana etc')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN users.c_level IS 'gives additional abilities within his organization')
    ActiveRecord::Base.connection.execute(query).values.inspect

    query = %(COMMENT ON COLUMN answers.anonymous_survey_participant_id IS 'mandatory for answers to anonymous survey')
    ActiveRecord::Base.connection.execute(query).values.inspect
  end
end
