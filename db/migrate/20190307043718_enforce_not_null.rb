# frozen_string_literal: true

class EnforceNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :preemptive_leaderbits, :added_by_user_id, false
    change_column_null :preemptive_leaderbits, :user_id, false
    change_column_null :preemptive_leaderbits, :leaderbit_id, false

    change_column_null :anonymous_survey_completed_sessions, :user_id, false

    change_column_null :anonymous_survey_participants, :added_by_user_id, false

    #this one fails, right? could be nil if "by_user_with_email" is present?
    #change_column_null :answers, :user_id, false

    change_column_null :answers, :question_id, false

    change_column_null :api_usages, :user_id, false

    change_column_null :boomerang_leaderbits, :user_id, false
    change_column_null :boomerang_leaderbits, :leaderbit_id, false

    change_column_null :email_authentication_tokens, :user_id, false

    change_column_null :entries, :leaderbit_id, false
    change_column_null :entries, :user_id, false
    change_column_null :entries, :entry_group_id, false

    change_column_null :entry_groups, :leaderbit_id, false
    change_column_null :entry_groups, :user_id, false

    change_column_null :entry_replies, :user_id, false
    change_column_null :entry_replies, :entry_id, false

    change_column_null :leaderbit_logs, :user_id, false
    change_column_null :leaderbit_logs, :leaderbit_id, false

    change_column_null :leaderbit_schedules, :leaderbit_id, false
    change_column_null :leaderbit_schedules, :schedule_id, false

    change_column_null :leaderbit_tags, :leaderbit_id, false

    change_column_null :leaderbit_video_usages, :user_id, false
    change_column_null :leaderbit_video_usages, :leaderbit_id, false

    change_column_null :momentum_historic_values, :user_id, false
    change_column_null :points, :user_id, false

    change_column_null :progress_report_recipients, :added_by_user_id, false
    change_column_null :progress_report_recipients, :user_id, false

    change_column_null :question_tags, :question_id, false
    change_column_null :questions, :survey_id, false

    change_column_null :teams, :organization_id, false

    change_column_null :user_mentees, :mentor_user_id, false
    change_column_null :user_mentees, :mentee_user_id, false

    change_column_null :user_seen_entry_groups, :user_id, false
    change_column_null :user_seen_entry_groups, :entry_group_id, false

    change_column_null :user_sent_emails, :user_id, false

    change_column_null :users, :organization_id, false

    change_column_null :vacation_modes, :user_id, false
  end
end
