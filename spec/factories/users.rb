# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                                                                                                                                                          :bigint(8)        not null, primary key
#  email                                                                                                                                                                       :string           default(""), not null
#  encrypted_password                                                                                                                                                          :string           default(""), not null
#  reset_password_token                                                                                                                                                        :string
#  reset_password_sent_at                                                                                                                                                      :datetime
#  remember_created_at                                                                                                                                                         :datetime
#  sign_in_count                                                                                                                                                               :integer          default(0), not null
#  current_sign_in_at                                                                                                                                                          :datetime
#  last_sign_in_at                                                                                                                                                             :datetime
#  current_sign_in_ip                                                                                                                                                          :inet
#  last_sign_in_ip                                                                                                                                                             :inet
#  created_at                                                                                                                                                                  :datetime         not null
#  updated_at                                                                                                                                                                  :datetime         not null
#  organization_id                                                                                                                                                             :bigint(8)        not null
#  time_zone                                                                                                                                                                   :string
#  authentication_token                                                                                                                                                        :string(30)
#  hour_of_day_to_send                                                                                                                                                         :integer          not null
#  day_of_week_to_send                                                                                                                                                         :string           not null
#  uuid                                                                                                                                                                        :string           not null
#  intercom_user_id                                                                                                                                                            :string
#  discarded_at                                                                                                                                                                :datetime
#  schedule_id                                                                                                                                                                 :integer
#  leaderbits_sending_enabled                                                                                                                                                  :boolean          default(TRUE), not null
#  welcome_video_seen_seconds                                                                                                                                                  :integer
#  notify_me_if_i_missing_2_weeks_in_a_row(accountability feature)                                                                                                             :boolean          default(TRUE)
#  notify_observer_if_im_trying_to_hide(accountability feature)                                                                                                                :boolean          default(FALSE)
#  notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks(accountability feature)                                                                                     :bigint(8)
#  admin_notes                                                                                                                                                                 :text
#  admin_notes_updated_at                                                                                                                                                      :datetime
#  last_seen_audit_created_at(needed for properly counting unseen new audit logs in Admin interface)                                                                           :datetime
#  goes_through_leader_welcome_video_onboarding_step(1st step by default for a new leader)                                                                                     :boolean          not null
#  goes_through_organizational_mentorship_onboarding_step(4th step by default for a new leader)                                                                                :boolean          not null
#  c_level(gives additional abilities within his organization)                                                                                                                 :boolean          default(FALSE), not null
#  system_admin(highest role in the system - Joel, Fabiana etc)                                                                                                                :boolean          default(FALSE), not null
#  personalized_leaderbits_algorithm_instead_of_regular_schedule                                                                                                               :boolean
#  goes_through_leader_strength_finder_onboarding_step(2nd step by default for a new leader)                                                                                   :boolean          not null
#  goes_through_team_survey_360_onboarding_step(3rd step by default for a new leader)                                                                                          :boolean          not null
#  created_by_user_id(needed so that we can distinguish users created by admin/employee from those created by organizational mentors)                                          :integer
#  can_create_a_mentee                                                                                                                                                         :boolean          default(FALSE), not null
#  name                                                                                                                                                                        :string
#  last_completed_onboarding_step_for_active_recipient(applies only to active recipients, for others there is #first_entry_for_non_active_leaderbits_recipient_user_to_review) :string
#
# Foreign Keys
#
#  fk_rails_...  (notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks => progress_report_recipients.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (schedule_id => schedules.id)
#

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email {
      handle = Faker::Internet.user_name(specifier: name, separators: %w(. _ -))
      # NOTE: it is important not to use fake .example.com emails because it may affect Postmark rating
      "#{handle}@leaderbits.io" # any@leaderbits.io doesn't trigger hard bounces
    }

    password { 'Password1' }

    goes_through_leader_welcome_video_onboarding_step { [true, false].sample }

    goes_through_leader_strength_finder_onboarding_step { [true, false].sample }
    goes_through_team_survey_360_onboarding_step { [true, false].sample }
    goes_through_organizational_mentorship_onboarding_step { [true, false].sample }

    can_create_a_mentee { [true, false].sample }

    leaderbits_sending_enabled { true }

    schedule
    organization

    c_level { false }
    system_admin { false }
    #c_level { [true, false].sample }
    #system_admin { [true, false].sample }
    personalized_leaderbits_algorithm_instead_of_regular_schedule { [true, false, nil].sample }

    notify_observer_if_im_trying_to_hide { [true, false].sample }
    admin_notes { ["How strongly do you agree with this statement: #{Faker::Hacker.say_something_smart}", nil].sample }

    hour_of_day_to_send { rand(7..10) }
    day_of_week_to_send { %w(Monday Tuesday).sample }
    time_zone { ActiveSupport::TimeZone.all.sample.name }

    after(:build) do |user, _evaluator|
      user.created_by_user = User.all.sample if user.created_by_user.blank?
    end
  end

  # for admin/controller specs, for sign in
  factory :system_admin_user, parent: :user do
    system_admin { true }

    # because in specs we don't need to test any of these for system admins
    goes_through_leader_welcome_video_onboarding_step { false }
    goes_through_leader_strength_finder_onboarding_step { false }
    goes_through_team_survey_360_onboarding_step { false }
    goes_through_organizational_mentorship_onboarding_step { false }
  end

  factory :c_level_user, parent: :user do
    c_level { true }
  end

  # for admin/controller specs, for sign in
  factory :employee_user, parent: :user do
    after(:create) do |user, _evaluator|
      LeaderbitsEmployee.create! user: user, organization: create(:organization)
    end
  end

  factory :team_leader_user, parent: :user do
    after(:create) do |user, _evaluator|
      team = FactoryBot.create(:team, organization: user.organization)

      TeamMember.create! user: user, team: team, role: TeamMember::Roles::LEADER
    end
  end

  factory :team_member_user, parent: :user do
    after(:create) do |user, _evaluator|
      team = FactoryBot.create(:team, organization: user.organization)

      TeamMember.create! user: user, team: team, role: TeamMember::Roles::MEMBER
    end
  end
end
