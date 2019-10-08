# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_22_105320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "anonymous_survey_participants", force: :cascade do |t|
    t.bigint "added_by_user_id", null: false, comment: "leader-user who requested (email; name) to participate in anonymous survey"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.string "uuid", null: false, comment: "needed because we can identify anon user only by this field as GET param accessed from sent email where we requested to participate in survey"
    t.string "name", null: false
    t.string "role", null: false
    t.index ["added_by_user_id"], name: "index_anonymous_survey_participants_on_added_by_user_id"
  end

  create_table "answers", comment: "Answers by users to survey questions", force: :cascade do |t|
    t.bigint "user_id", comment: "Present in case that is leader-user answering Survey::Types::FOR_LEADER question"
    t.bigint "question_id", null: false
    t.json "params", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "anonymous_survey_participant_id", comment: "mandatory for answers to anonymous survey"
    t.index ["anonymous_survey_participant_id"], name: "index_answers_on_anonymous_survey_participant_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "boomerang_leaderbits", comment: "way for user to be reminded about his own entry(entries) in the future and probably retake the challenge", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.bigint "leaderbit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leaderbit_id"], name: "index_boomerang_leaderbits_on_leaderbit_id"
    t.index ["user_id"], name: "index_boomerang_leaderbits_on_user_id"
  end

  create_table "bounced_emails", comment: "users with such emails are excluded from sending emails - sometimes we are provided with invalid emails or they become invalid over time", force: :cascade do |t|
    t.string "email", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_bounced_emails_on_email", unique: true
  end

  create_table "email_authentication_tokens", comment: "needed so that simple_token_authentication auto-login links dont last longer than 3 weeks", force: :cascade do |t|
    t.string "authentication_token", limit: 30, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "valid_until"
    t.index ["user_id"], name: "index_email_authentication_tokens_on_user_id"
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "leaderbit_id", null: false
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.bigint "entry_group_id", null: false
    t.datetime "content_updated_at", comment: "needed to reliably separate actual content update time from nested :touch => true ActiveRecord triggers"
    t.boolean "visible_to_my_mentors", default: false, null: false
    t.boolean "visible_to_my_peers", default: false, null: false
    t.boolean "visible_to_community_anonymously", default: false, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_entries_on_discarded_at"
    t.index ["entry_group_id"], name: "index_entries_on_entry_group_id"
    t.index ["leaderbit_id"], name: "index_entries_on_leaderbit_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "entry_groups", comment: "needed because leaders may post several entries by leaderbit and we need to display them as group and mark them as read as a group", force: :cascade do |t|
    t.bigint "leaderbit_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leaderbit_id"], name: "index_entry_groups_on_leaderbit_id"
    t.index ["user_id"], name: "index_entry_groups_on_user_id"
  end

  create_table "entry_replies", comment: "replies to entries by system-admin/Joel, mentors, employees and replies to entry_replies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "entry_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_reply_id"
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.index ["entry_id"], name: "index_entry_replies_on_entry_id"
    t.index ["user_id"], name: "index_entry_replies_on_user_id"
  end

  create_table "hourly_leaderbit_sending_summaries", force: :cascade do |t|
    t.integer "to_be_sent_quantity"
    t.integer "actual_sent_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ip_address_details", comment: "Used for displaying users on map(mapbox) in the Blazer query", force: :cascade do |t|
    t.inet "ip", null: false
    t.string "country_name"
    t.string "city"
    t.string "region"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.json "raw_params"
    t.index ["ip"], name: "index_ip_address_details_on_ip"
  end

  create_table "leaderbit_employee_mentorships", force: :cascade do |t|
    t.bigint "mentor_user_id"
    t.bigint "mentee_user_id"
    t.datetime "created_at"
    t.index ["mentee_user_id"], name: "index_leaderbit_employee_mentorships_on_mentee_user_id"
    t.index ["mentor_user_id"], name: "index_leaderbit_employee_mentorships_on_mentor_user_id"
  end

  create_table "leaderbit_logs", comment: "stores in which statuses leaderbits are for user - started, completed etc", force: :cascade do |t|
    t.bigint "leaderbit_id", null: false
    t.bigint "user_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leaderbit_id"], name: "index_leaderbit_logs_on_leaderbit_id"
    t.index ["user_id"], name: "index_leaderbit_logs_on_user_id"
  end

  create_table "leaderbit_schedules", force: :cascade do |t|
    t.bigint "leaderbit_id", null: false
    t.bigint "schedule_id", null: false
    t.integer "position"
    t.index ["leaderbit_id"], name: "index_leaderbit_schedules_on_leaderbit_id"
    t.index ["schedule_id"], name: "index_leaderbit_schedules_on_schedule_id"
  end

  create_table "leaderbit_tags", comment: "used for labeling leaderbits. Needed for matching them to survey question tags which is needed for future more intelligent leaderbit scheduling algorithms", force: :cascade do |t|
    t.string "label", null: false
    t.bigint "leaderbit_id", null: false
    t.datetime "created_at", null: false
    t.index ["leaderbit_id"], name: "index_leaderbit_tags_on_leaderbit_id"
  end

  create_table "leaderbit_video_usages", comment: "used for tracking total leaderbit video watch time by user because Vimeo does not give us such info. Needed because same video could be seen multiple times and we need to know how it changes overtime", force: :cascade do |t|
    t.string "video_session_id", null: false, comment: "uniq identifier that is generated per page view. In periodic AJAX requests we are incrementing #seconds_watched by providing this identifier."
    t.integer "seconds_watched", null: false
    t.bigint "user_id", null: false
    t.bigint "leaderbit_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration", null: false
    t.index ["leaderbit_id"], name: "index_leaderbit_video_usages_on_leaderbit_id"
    t.index ["user_id"], name: "index_leaderbit_video_usages_on_user_id"
  end

  create_table "leaderbits", force: :cascade do |t|
    t.string "name", null: false
    t.text "desc", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image", default: "default.png"
    t.text "body", null: false
    t.boolean "active", default: false
    t.string "user_action_title_suffix", null: false
    t.text "entry_prefilled_text"
  end

  create_table "leaderbits_employees", comment: "users in the system who are official LeaderBits Employees - Allison, Fabiana, Courtney etc", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_leaderbits_employees_on_organization_id"
    t.index ["user_id"], name: "index_leaderbits_employees_on_user_id"
  end

  create_table "momentum_historic_values", comment: "user for tracking how users momentum is changing over time. Important metric that is used in many graphs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.date "created_on", null: false
    t.index ["created_on"], name: "index_momentum_historic_values_on_created_on"
    t.index ["user_id"], name: "index_momentum_historic_values_on_user_id"
  end

  create_table "organizational_mentorships", force: :cascade do |t|
    t.bigint "mentor_user_id", null: false
    t.bigint "mentee_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "accepted_at"
    t.index ["mentee_user_id"], name: "index_organizational_mentorships_on_mentee_user_id"
    t.index ["mentor_user_id"], name: "index_organizational_mentorships_on_mentor_user_id"
  end

  create_table "organizations", comment: "Joel and team is more used to term *Account* but technically organization is more descriptive", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "first_leaderbit_introduction_message"
    t.integer "hour_of_day_to_send", default: 9
    t.string "day_of_week_to_send", default: "Monday"
    t.datetime "discarded_at"
    t.integer "custom_default_schedule_id"
    t.boolean "leaderbits_sending_enabled", default: true, null: false
    t.string "stripe_customer_id"
    t.datetime "active_since", null: false, comment: "needed in cases when organization is created prematurely but it must be activated on certain date"
    t.integer "users_count"
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
  end

  create_table "points", comment: "points given to user for certain actions - needed for leveling him up over time and displaying additional features", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.string "type", null: false
    t.string "pointable_type", null: false
    t.integer "pointable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "preemptive_leaderbits", comment: "separate leaderbit schedule that puts users default schedule on pause until whole preemptive leaderbit queue is sent", force: :cascade do |t|
    t.bigint "leaderbit_id", null: false
    t.bigint "user_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_user_id", null: false
    t.index ["added_by_user_id"], name: "index_preemptive_leaderbits_on_added_by_user_id"
    t.index ["leaderbit_id"], name: "index_preemptive_leaderbits_on_leaderbit_id"
    t.index ["user_id"], name: "index_preemptive_leaderbits_on_user_id"
  end

  create_table "progress_report_recipients", comment: "manageable from the Accountability page", force: :cascade do |t|
    t.string "frequency", null: false
    t.bigint "added_by_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["added_by_user_id"], name: "index_progress_report_recipients_on_added_by_user_id"
    t.index ["user_id"], name: "index_progress_report_recipients_on_user_id"
  end

  create_table "question_tags", comment: "used for labeling survey questions. Needed for matching them to leaderbit tags which is needed for future more intelligent leaderbit scheduling algorithms", force: :cascade do |t|
    t.string "label", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.index ["question_id"], name: "index_question_tags_on_question_id"
  end

  create_table "questions", comment: "survey questions - contains both types leadership surveying and anonymous survey on how you view your leader", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.json "params", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "anonymous_survey_similarity_uuid"
    t.boolean "count_as_reverse", default: false
    t.index ["survey_id"], name: "index_questions_on_survey_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "cloned_from_id"
    t.integer "users_count", default: 0
  end

  create_table "surveys", comment: "contains both types - leadership surveying and anonymous survey on how you view your leader", force: :cascade do |t|
    t.string "type", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "anonymous_survey_participant_role"
  end

  create_table "team_members", force: :cascade do |t|
    t.string "role", null: false
    t.bigint "user_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_team_members_on_role"
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", comment: "teams within organization. Originally was needed because there was special roles - team leader, leader of team leaders, team member. upd. Not sure if we still need it", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_teams_on_organization_id"
  end

  create_table "user_seen_entry_groups", comment: "needed for tracking entry group *Seen*/*Mark as Read* status", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "entry_group_id", null: false
    t.datetime "created_at", null: false
    t.index ["entry_group_id"], name: "index_user_seen_entry_groups_on_entry_group_id"
    t.index ["user_id"], name: "index_user_seen_entry_groups_on_user_id"
  end

  create_table "user_sent_emails", comment: "STI table where we store all emails that we sent to each user. Needed for transparency and tracking last-time-sent-at for periodic email reports - e.g. monthly", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.string "resource_type"
    t.string "type"
    t.json "params"
    t.index ["resource_id"], name: "index_user_sent_emails_on_resource_id"
    t.index ["user_id"], name: "index_user_sent_emails_on_user_id"
  end

  create_table "user_strength_levels", force: :cascade do |t|
    t.string "symbol_name"
    t.bigint "user_id", null: false
    t.integer "value"
    t.index ["user_id"], name: "index_user_strength_levels_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.string "time_zone"
    t.string "authentication_token", limit: 30
    t.integer "hour_of_day_to_send", null: false
    t.string "day_of_week_to_send", null: false
    t.string "uuid", null: false
    t.string "intercom_user_id"
    t.datetime "discarded_at"
    t.integer "schedule_id"
    t.boolean "leaderbits_sending_enabled", default: true, null: false
    t.integer "welcome_video_seen_seconds"
    t.boolean "notify_me_if_i_missing_2_weeks_in_a_row", default: true, comment: "accountability feature"
    t.boolean "notify_observer_if_im_trying_to_hide", default: false, comment: "accountability feature"
    t.bigint "notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks", comment: "accountability feature"
    t.text "admin_notes"
    t.datetime "admin_notes_updated_at"
    t.datetime "last_seen_audit_created_at", comment: "needed for properly counting unseen new audit logs in Admin interface"
    t.boolean "goes_through_leader_welcome_video_onboarding_step", null: false, comment: "1st step by default for a new leader"
    t.boolean "goes_through_organizational_mentorship_onboarding_step", null: false, comment: "4th step by default for a new leader"
    t.boolean "c_level", default: false, null: false, comment: "gives additional abilities within his organization"
    t.boolean "system_admin", default: false, null: false, comment: "highest role in the system - Joel, Fabiana etc"
    t.boolean "personalized_leaderbits_algorithm_instead_of_regular_schedule"
    t.boolean "goes_through_leader_strength_finder_onboarding_step", null: false, comment: "2nd step by default for a new leader"
    t.boolean "goes_through_team_survey_360_onboarding_step", null: false, comment: "3rd step by default for a new leader"
    t.integer "created_by_user_id", comment: "needed so that we can distinguish users created by admin/employee from those created by organizational mentors"
    t.boolean "can_create_a_mentee", default: false, null: false
    t.string "name"
    t.string "last_completed_onboarding_step_for_active_recipient", comment: "applies only to active recipients, for others there is #first_entry_for_non_active_leaderbits_recipient_user_to_review"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  create_table "vacation_modes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "reason"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vacation_modes_on_user_id"
  end

  create_table "votes", force: :cascade do |t|
    t.string "votable_type"
    t.bigint "votable_id"
    t.string "voter_type"
    t.bigint "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter_type_and_voter_id"
  end

  add_foreign_key "anonymous_survey_participants", "users", column: "added_by_user_id"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "boomerang_leaderbits", "leaderbits"
  add_foreign_key "boomerang_leaderbits", "users"
  add_foreign_key "email_authentication_tokens", "users"
  add_foreign_key "entries", "entry_groups"
  add_foreign_key "entries", "leaderbits"
  add_foreign_key "entries", "users"
  add_foreign_key "entry_groups", "leaderbits"
  add_foreign_key "entry_groups", "users"
  add_foreign_key "entry_replies", "entries"
  add_foreign_key "entry_replies", "entry_replies", column: "parent_reply_id"
  add_foreign_key "entry_replies", "users"
  add_foreign_key "leaderbit_employee_mentorships", "users", column: "mentee_user_id"
  add_foreign_key "leaderbit_employee_mentorships", "users", column: "mentor_user_id"
  add_foreign_key "leaderbit_logs", "leaderbits"
  add_foreign_key "leaderbit_logs", "users"
  add_foreign_key "leaderbit_schedules", "leaderbits"
  add_foreign_key "leaderbit_schedules", "schedules"
  add_foreign_key "leaderbit_tags", "leaderbits"
  add_foreign_key "leaderbit_video_usages", "leaderbits"
  add_foreign_key "leaderbit_video_usages", "users"
  add_foreign_key "momentum_historic_values", "users"
  add_foreign_key "organizational_mentorships", "users", column: "mentee_user_id"
  add_foreign_key "organizational_mentorships", "users", column: "mentor_user_id"
  add_foreign_key "points", "users"
  add_foreign_key "preemptive_leaderbits", "leaderbits"
  add_foreign_key "preemptive_leaderbits", "users"
  add_foreign_key "preemptive_leaderbits", "users", column: "added_by_user_id"
  add_foreign_key "progress_report_recipients", "users"
  add_foreign_key "progress_report_recipients", "users", column: "added_by_user_id"
  add_foreign_key "question_tags", "questions"
  add_foreign_key "questions", "surveys"
  add_foreign_key "schedules", "schedules", column: "cloned_from_id"
  add_foreign_key "teams", "organizations"
  add_foreign_key "user_seen_entry_groups", "entry_groups"
  add_foreign_key "user_seen_entry_groups", "users"
  add_foreign_key "user_sent_emails", "users"
  add_foreign_key "user_strength_levels", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "progress_report_recipients", column: "notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks"
  add_foreign_key "users", "schedules"
  add_foreign_key "vacation_modes", "users"
end
