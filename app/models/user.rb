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

class User < ApplicationRecord
  acts_as_voter
  audited except: %i[
    admin_notes_updated_at
    authentication_token
    current_sign_in_at
    current_sign_in_ip
    encrypted_password
    intercom_user_id
    last_sign_in_at
    last_sign_in_ip
    notify_me_if_i_missing_2_weeks_in_a_row
    notify_observer_if_im_trying_to_hide
    notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks
    remember_created_at
    reset_password_sent_at
    reset_password_token
    sign_in_count
    uuid
    welcome_video_seen_seconds
  ], associated_with: :organization

  acts_as_token_authenticatable

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  include ActsAsIntercomUser
  include ActsAsSoftDeletedUser
  include ActsAsUuidModel

  module OnboardingSteps
    WELCOME_VIDEO_ONBOARDING_STEP = 'welcome_video_onboarding_step'
    LEADER_STRENGTH_FINDER_ONBOARDING_STEP = 'leader_strength_finder_onboarding_step'
    TEAM_SURVEY_360_ONBOARDING_STEP = 'team_survey_360_onboarding_step'

    ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP = 'organizational_mentorship_onboarding_step'

    #NOTE: order is not important here
    ALL = [
      WELCOME_VIDEO_ONBOARDING_STEP,
      ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP,
      LEADER_STRENGTH_FINDER_ONBOARDING_STEP,
      TEAM_SURVEY_360_ONBOARDING_STEP
    ].freeze
  end

  # not need to :touch user because it is cached as composite key anyway(cache [user, entry])
  belongs_to :organization, counter_cache: true

  #optional true because
  # allow schedule to be nil(needed for progress report participants users which are not real leader-users, more like spectators)
  belongs_to :schedule, counter_cache: true, optional: true
  belongs_to :created_by_user, class_name: 'User', optional: true

  with_options dependent: :destroy do
    has_many :anonymous_survey_participants, foreign_key: 'added_by_user_id'
    has_many :answers
    has_many :boomerang_leaderbits
    has_many :entries
    has_many :entry_groups
    has_many :email_authentication_tokens
    has_many :leaderbit_logs
    has_many :momentum_historic_values
    has_many :points
    has_many :preemptive_leaderbits
    has_many :progress_report_recipients, foreign_key: 'added_by_user_id'
    has_many :entry_replies
    has_many :strength_levels, class_name: 'UserStrengthLevel'
    has_many :user_sent_emails #STI parent model
    has_many :vacation_modes
    has_many :video_usages, class_name: 'LeaderbitVideoUsage'
  end
  # no need in dependent destroying as it is STI model
  has_many :user_sent_dont_quits
  has_many :user_sent_scheduled_new_leaderbits
  has_many :user_sent_monthly_progress_reports
  has_many :user_sent_progress_dumps
  has_many :user_sent_user_is_progressing_as_leaders
  has_many :user_sent_leader_is_slacking_offs

  # if you want to move it to :destroy option instead, try to delete all users locally with production dump
  # verify that it doesn't fall
  # and verity that all user-related entries are deleted
  has_many :user_seen_entry_groups, dependent: :delete_all

  accepts_nested_attributes_for :organization
  #accepts_nested_attributes_for :anonymous_survey_participants, allow_destroy: true
  #accepts_nested_attributes_for :progress_report_recipients, allow_destroy: true
  #accepts_nested_attributes_for :mentee_users, allow_destroy: true

  #allow schedule to be nil(needed for progress report participants users which are not real leader-users, more like spectators)
  validates :schedule, presence: true, allow_nil: true
  validates :created_by_user, presence: true, on: :create, if: -> { User.count.positive? } #workaround to create the first user in test env

  #NOTE: avoid enforcing this validation for all existing users because they would be very surprised being forced to complete missing onboarding step a few months using the system
  validates_inclusion_of :last_completed_onboarding_step_for_active_recipient, in: OnboardingSteps::ALL, unless: -> { last_completed_onboarding_step_for_active_recipient.nil? }

  validates :name, presence: true, if: :validate_name?
  #NOTE: this validation may probably become optional for non-active recipients
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name)

  validates :hour_of_day_to_send, inclusion: { in: 0..23 }, allow_nil: false, allow_blank: false
  validates :day_of_week_to_send, inclusion: { in: Date::DAYNAMES }, allow_nil: false, allow_blank: false

  before_save :trying_to_hide_by_changing_slacking_off_selector, if: :trying_to_hide_by_changing_slacking_off_selector?
  before_save :trying_to_hide_by_switching_off_trying_to_hide, if: :trying_to_hide_by_switching_off_trying_to_hide?

  before_destroy { OrganizationalMentorship.where('mentor_user_id = ? OR mentee_user_id = ?', id, id).delete_all }
  after_destroy { DeleteFromIntercom.perform_later(email) }

  # @return [String] e.g. "N7nU4vSVNEvRf-CWkjiU"
  def issue_new_authentication_token_and_return
    ActiveRecord::Base.transaction do
      # @see https://github.com/gonzalo-bulnes/simple_token_authentication#tokens-generation
      # @see lib/simple_token_authentication/acts_as_token_authenticatable.rb

      new_token = generate_unique_authentication_token
      self.authentication_token = new_token
      save!

      # no need to manually expire existing/previous auth token, let it expire naturally

      email_authentication_tokens
        .create!(authentication_token: new_token,
                 valid_until: EmailAuthenticationToken::NEW_AUTHENTICATION_TOKEN_SHELF_LIFE.from_now)

      new_token
    end
  end

  #NOTE: it updates to new_step only if current :last_completed_onboarding_step_for_active_recipient goes prior to new_step in UserOnboarding sequence
  def update_last_completed_onboarding_step(new_step)
    if last_completed_onboarding_step_for_active_recipient.blank?
      self.last_completed_onboarding_step_for_active_recipient = new_step
      save!
    else
      onboarding = UserOnboarding.new(self)
      next_step = onboarding.next_step_after last_completed_onboarding_step_for_active_recipient
      if new_step == next_step
        self.last_completed_onboarding_step_for_active_recipient = new_step
        save!
      end
    end
  end

  def first_name
    NameOfPerson::PersonName.full(name).first
  end

  def name_initials
    NameOfPerson::PersonName.full(name).initials
  end

  # Originally this feature was requested by Joel so that he could easily and quickly understand
  # what plan/schedule is on.
  def can_see_schedule_name_in_entries_list?
    system_admin? || leaderbits_employee_with_access_to_any_organization?
  end

  def existing_password_exists?
    encrypted_password.present?
  end

  #NOTE: schedule_id check is needed because we have *technical* users(originally progress report participants)
  # they don't have schedule, no leaderbits to receive. They just see some leader progress updates. Excluding them from sending
  def active_scheduled_leaderbits_receiver?
    !discarded? &&
      schedule_id.present? &&
      leaderbits_sending_enabled? &&
      organization.leaderbits_sending_enabled?
  end

  # @return [Integer]
  def missed_weeks_quantity
    time1 = leaderbit_logs.completed.order(updated_at: :desc).first&.updated_at
    time2 = video_usages.order(created_at: :desc).first&.created_at
    time3 = entries.order(created_at: :desc).first&.created_at
    time4 = created_at
    time5 = organization.active_since

    was_active_most_recently_at = [time1, time2, time3, time4, time5].compact.max

    ((Time.now - was_active_most_recently_at.beginning_of_day) / (3600 * 24 * 7)).floor
  end

  def technical_user_progress_report_recipient?
    #TODO-low check discarded_at presence as well?
    schedule_id.blank?
  end

  # This method is needed for making emails feel a bit more personal
  # @return [String] "John Brown <j@domain.com>"
  def as_email_to
    return email if name.nil?

    %(#{name} <#{email}>)
  end

  def increment_welcome_video_seconds_watched!
    attribute = 'welcome_video_seen_seconds'

    original_value_sql = "CASE WHEN #{attribute} IS NULL THEN 0 ELSE #{attribute} END"
    self.class.where(id: id).update_all("#{attribute} = #{original_value_sql} + 1")
    reload
  end

  #TODO-low or seen?
  def read?(entry_group:)
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}/#{entry_group.id}") do
      UserSeenEntryGroup.where(user: self, entry_group: entry_group).exists?
    end
  end
  alias :seen? :read?

  def last_completed_leaderbit_as_string
    Rails.cache.fetch "#{__method__}/#{cache_key_with_version}/v2" do
      last_completed_leaderbit_log&.leaderbit&.name.to_s.gsub('Challenge: ', '')
    end
  end

  # @return [Team]
  def leader_in_teams
    @leader_in_teams ||= TeamMember.includes(:team).where(role: TeamMember::Roles::LEADER, user: self).collect(&:team)
  end

  # @return [Team]
  def member_in_teams
    @member_in_teams ||= TeamMember.includes(:team).where(role: TeamMember::Roles::MEMBER, user: self).collect(&:team)
  end

  def team_leader_in_any_team?
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      leader_in_teams.present?
    end
  end

  def mentor_for_any_user?
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      OrganizationalMentorship.where(mentor_user_id: id).exists?
    end
  end

  def team_member_in_any_team?
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      member_in_teams.present?
    end
  end

  # NOTE: this method is currently used only for Engagement Screen, right column selector
  # IMPORTANT: it might be requested by C-Level users who are part of any team(but still need to be able to see them on this page)
  # @return [Team]
  def with_access_to_teams_with_any_role
    if c_level?
      organization.teams
    else
      TeamMember.includes(:team).where(user: self).collect(&:team)
    end
  end

  def welcome_video_seen_percentage
    result = welcome_video_seen_seconds / Rails.configuration.welcome_video_duration.to_f

    return 100 if result > 1

    result * 100
  end

  def leaderbits_employee_with_access_to_organizations
    @leaderbits_employee_with_access_to_organizations ||= LeaderbitsEmployee
                                                            .includes(:organization)
                                                            .where(user: self)
                                                            .collect(&:organization)
  end

  def leaderbits_employee_with_access_to_any_organization?
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      LeaderbitsEmployee.where(user: self).exists?
    end
  end

  def access_to_admin_interface?
    system_admin? || leaderbits_employee_with_access_to_any_organization?
  end

  #TODO-low does it really belong here?
  #TODO: rename because it is not only for entry authors
  def name_when_entry_author
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}/#{organization.users_count}") do
      full_form = "#{name} @ #{organization.name}"
      next(full_form) unless organization.individual?

      name == organization.name ? name : full_form
    end
  end

  # extracted to explicitely group/grep related functionality
  # and because it doesn't belong to pundit policy which is more permissive and abstract-level
  def can_make_leaderbit_active?
    system_admin?
  end

  # unique name so that it doesn't conflict with acts_as_votable own methods
  # NOTE: liking doesn't update user's updated_at
  def favorited?(entry_or_reply)
    Rails.cache.fetch("#{__method__}/#{id}/#{entry_or_reply.cache_key_with_version}") do
      liked? entry_or_reply
    end
  end

  #TODO-low there could be multiple in-progress leaderbits. Why are we always returning the first one?
  # @return [Leaderbit] or nil in case there is no in-progress leaderbit for user
  def current_leaderbit_in_progress
    @current_leaderbit_in_progress ||= leaderbit_logs.in_progress.first&.leaderbit
  end

  # @return [Integer]
  def points_for_latest_event
    points.last.value
  end

  # this method is used very frequently
  def total_points
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      points.sum(:value)
    end
  end

  def to_param
    uuid
  end

  # @return [Leaderbit]
  def next_leaderbit_to_send
    priority_queue = upcoming_active_preemptive_leaderbits
    return priority_queue.first if priority_queue.present?

    if personalized_leaderbits_algorithm_instead_of_regular_schedule?
      exclude_leaderbit_ids = received_uniq_leaderbit_ids
      PersonalizedLeaderbitsQueue.new(self).call.reject { |leaderbit| exclude_leaderbit_ids.include?(leaderbit.id) }.first
    else
      upcoming_active_leaderbits_from_schedule.first
    end
  end

  # @return [[Leaderbit]]
  def unfinished_leaderbits_we_havent_notified_about
    if next_leaderbit_to_send.present?
      raise("in #{__method__} user #{id} #{email} has to receive scheduled leaderbits first before we send unfinished leaderbits reminders")
    end

    schedule
      .leaderbit_schedules
      .yield_self(&method(:only_active_leaderbits))
      .where('leaderbits.id NOT IN(SELECT leaderbit_id FROM leaderbit_logs WHERE user_id = ? AND status = ?)', id, LeaderbitLog::Statuses::COMPLETED)
      .where('leaderbits.id NOT IN(SELECT resource_id FROM user_sent_emails WHERE user_id = ? AND type = ? AND resource_type = ?)', id, UserSentIncompleteLeaderbitReminder.to_s, Leaderbit.to_s)
      .collect(&:leaderbit)
  end

  # NOTE: this method takes into account both sent emails - scheduled and manually sent
  # NOTE: this method includes both - leaderbit_logs records & user_sent_scheduled_new_leaderbits to cover all use cases and old migrations artefacts
  # @return [Array] each leaderbit id is present only once even if user received some leaderbit multiple times
  def received_uniq_leaderbit_ids
    Rails.cache.fetch("#{__method__}/#{cache_key_with_version}") do
      query = <<-SQL.squish
        SELECT "leaderbit_logs"."leaderbit_id" FROM "leaderbit_logs"
          WHERE "leaderbit_logs"."user_id" = #{id}
          UNION SELECT "user_sent_emails"."resource_id" FROM "user_sent_emails"
            WHERE "user_sent_emails"."type" = #{ActiveRecord::Base.connection.quote UserSentScheduledNewLeaderbit}
              AND "user_sent_emails"."resource_type" = #{ActiveRecord::Base.connection.quote Leaderbit}
              AND "user_sent_emails"."user_id" = #{id}
      SQL

      ActiveRecord::Base.connection.execute(query).values.flatten
    end
  end

  # NOTE: this method takes into account both sent emails - scheduled and manually sent
  # NOTE: this method includes both - leaderbit_logs records & user_sent_scheduled_new_leaderbits to cover all use cases and old migrations artefacts
  # @return [Array] each leaderbit id is present only once even if user received some leaderbit multiple times
  def received_uniq_leaderbit_ids_at_time(at_time)
    #NOTE no need to cache it because it is requested very rarely

    query = <<-SQL.squish
      SELECT "leaderbit_logs"."leaderbit_id" FROM "leaderbit_logs"
        WHERE "leaderbit_logs"."user_id" = #{id}
          AND "leaderbit_logs"."updated_at" <= #{ActiveRecord::Base.connection.quote at_time.to_s(:db)}
        UNION SELECT "user_sent_emails"."resource_id" FROM "user_sent_emails"
          WHERE "user_sent_emails"."type" = #{ActiveRecord::Base.connection.quote UserSentScheduledNewLeaderbit}
            AND "user_sent_emails"."resource_type" = #{ActiveRecord::Base.connection.quote Leaderbit}
            AND "user_sent_emails"."user_id" = #{id}
            AND "user_sent_emails"."created_at" <= #{ActiveRecord::Base.connection.quote at_time.to_s(:db)}
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten
  end

  # @return [Symbol] e.g. :highly_active or :active or :not_active
  def activity_type(since_at, until_at)
    completed_count = LeaderbitLog.completed.where(user: self).where('updated_at >= ? AND updated_at < ?', since_at, until_at).count

    received_leaderbit_ids_during_time_range = received_uniq_leaderbit_ids_at_time(until_at) - received_uniq_leaderbit_ids_at_time(since_at)

    if received_leaderbit_ids_during_time_range.count >= 20
      case completed_count
      #NOTE: completed counter could be greater than receive counter(user might have decided to have a really production week after some period of inactivity)
      when 0.85 * received_leaderbit_ids_during_time_range.count..Float::INFINITY
        :highly_active
      when 0..0.2 * received_leaderbit_ids_during_time_range.count
        :not_active
      else
        :active
      end
    else

      case completed_count
      #NOTE: completed counter could be greater than receive counter(user might have decided to have a really production week after some period of inactivity)
      when received_leaderbit_ids_during_time_range.count - 1..Float::INFINITY
        :highly_active
      when 0
        :not_active
      else
        :active
      end
    end
  end

  # @return [Integer]
  # NOTE: this method doesn't need caching because it is very rarely requested and not time critical
  def momentum_at_time(at_time)
    completed_count = leaderbit_logs
                        .completed
                        .where('updated_at < ?', at_time)
                        .uniq
                        .count

    if completed_count.zero?
      0
    else
      #NOTE: #received_uniq_leaderbit_ids is smart enough to utilize cache with nil argument
      total = received_uniq_leaderbit_ids_at_time(at_time).count.to_f

      (100 * completed_count / total).to_i.tap do |result|
        # NOTE: do not delete it.
        # that's how we're trying to find the cause for #159692118
        if result > 100
          Rollbar.info("Invalid momentum", momentum: result, user_id: id)
        end
      end
    end
  end

  # @return [Integer] it is important to always return integer because of historic momentum values' validation.
  def momentum
    # NOTE: Make sure cache_key is always updated in case of leaderbit log or UserSentScheduledLeaderbit user updates
    cache_key = "#{__method__}/#{cache_key_with_version}"

    Rails.cache.fetch(cache_key) do
      calculate_momentum
    end
  end

  # @return [Team]
  def might_have_role_in_teams
    result = []

    if c_level? || system_admin?
      result << organization.teams
    end

    if leaderbits_employee_with_access_to_any_organization?
      result << leaderbits_employee_with_access_to_organizations.collect(&:teams).flatten
    end

    result << leader_in_teams
    result.flatten.uniq
  end

  def can_see_users_in_organization_without_teams
    user_ids_with_teams = TeamMember
                            .where('team_id IN(SELECT id FROM teams WHERE organization_id = ?)', organization_id)
                            .pluck(:user_id)

    can_see_users_in_own_organization
      .where.not(id: user_ids_with_teams)
  end

  # @return [ActiveRecord::Relation]
  def can_see_users_in_own_organization
    if c_level?
      User
        .where('organization_id = ?', organization_id)
        .where.not(schedule_id: nil)
    else
      team_user_ids = can_see_user_ids_as_team_member_or_team_leader || [-1]
      organizational_mentorship_user_ids = can_see_user_ids_as_organizational_mentor_or_mentee || [-1]
      User.where("id = ? OR id IN(?) OR id IN(?)", id, team_user_ids, organizational_mentorship_user_ids)
    end
  end

  def can_see_user_ids_as_organizational_mentor_or_mentee
    OrganizationalMentorship
      .where('mentor_user_id = ? OR mentee_user_id = ?', id, id)
      .pluck(:mentor_user_id, :mentee_user_id)
      .flatten
  end

  #upd. Review the following notes to check whether they still make sense
  #NOTE: this method is purposely not-private for ease of testing
  #NOTE: this is the list of users that current_user can see in Company => Users
  # when he is a team leader or team member
  #NOTE: if role is higher than that then organization.users is used instead.
  # @return [ActiveRecord::Relation]
  def can_see_user_ids_as_team_member_or_team_leader
    user_has_access_to_team_ids = TeamMember.where(user: self).pluck(:team_id)

    TeamMember.where(team: user_has_access_to_team_ids).pluck(:user_id)
  end

  # This method is used for displaying in leaderbits#index
  # NOTE: at certain moments #next_leaderbit_to_be_sent_at is the same as #current_week_leaderbit_send_time
  # @return [ActiveSupport::TimeWithZone]
  def next_leaderbit_to_be_sent_at
    @next_leaderbit_to_be_sent_at ||= begin
      t1 = current_week_leaderbit_send_time

      Time.now < t1 ? t1 : 1.week.after(t1)
    end
  end

  # @return [ActiveSupport::TimeWithZone]
  def current_week_leaderbit_send_time
    tz = ActiveSupport::TimeZone[time_zone] || raise
    days_into_week_addition = { 'Monday' => 0, 'Tuesday' => 1, 'Wednesday' => 2, 'Thursday' => 3, 'Friday' => 4, 'Saturday' => 5, 'Sunday' => 6 }

    Time.use_zone(tz) do
      t = Time.zone.now.beginning_of_week
      days_into_week_addition.fetch(day_of_week_to_send)
        .days
        .since(t)
        .change(hour: hour_of_day_to_send)
    end
  end

  #NOTE: keep this method in sync with #upcoming_active_preemptive_leaderbits in any of these methods change
  # @return [Leaderbit]
  def all_preemptive_active_leaderbits
    preemptive_leaderbits
      .yield_self(&method(:only_active_leaderbits))
      .order(position: :asc)
      .collect(&:leaderbit)
  end

  #NOTE: keep this method in sync with #upcoming_active_leaderbits_from_schedule in any of these methods change
  # @return [Leaderbit]
  def all_active_leaderbits_from_schedule
    schedule
      .leaderbit_schedules
      .yield_self(&method(:only_active_leaderbits))
      .order(position: :asc)
      .collect(&:leaderbit)
  end

  # this method is needed in cases when user receives multiple leaderbits before following first "Watch Leaderbit" link from email
  # At that point user hasn't seen welcome video yet
  def first_leaderbit_to_start
    #TODO-High think about personalized leaderbits as well
    UserSentScheduledNewLeaderbit
      .where(user_id: id)
      .where('resource_id NOT IN(SELECT leaderbit_id FROM leaderbit_logs WHERE user_id = ?)', id)
      .order(created_at: :asc)
      .first
      &.resource
  end

  # @return [LeaderbitLog]
  def lifetime_completed_leaderbit_logs
    LeaderbitLog
      .completed
      .where(user: self)
      .includes(:leaderbit)
      .order(updated_at: :desc)
  end

  def combined_results_by_question
    #TODO - check dates as well
    # completed_session.created_on
    # answer.created_at
    Answer
      .joins(:question)
      .where("questions.params ->> 'type' = ?", Question::Types::SLIDER)
      .where('anonymous_survey_participant_id IN(SELECT id FROM anonymous_survey_participants WHERE added_by_user_id = ?)', id)
      .each_with_object({}) do |answer, hash|
      hash[answer.question.anonymous_survey_similarity_uuid] ||= []
      hash[answer.question.anonymous_survey_similarity_uuid] << answer
    end.each_with_object({}) do |question_with_answers, result|
      question_anonymous_survey_similarity_uuid = question_with_answers[0]
      answers = question_with_answers[1]

      values = answers.collect { |answer| answer.params['value'].to_i }
      average = values.inject(0.0) { |sum, el| sum + el } / values.count

      #NOTE: you may enhance sorting algorithm so that leader wouldn't be able to guess which answer was from which user
      #(he knows their emails and can sort them alphabetically)
      # fixes #164381217
      sorted_answers = answers.sort_by(&:anonymous_survey_participant_id)
      result[question_anonymous_survey_similarity_uuid] = { answers: sorted_answers, average: average }
    end.sort_by do |question_anonymous_survey_similarity_uuid, _v|
      question = Question
                   .where(anonymous_survey_similarity_uuid: question_anonymous_survey_similarity_uuid)
                   .where('surveys.type = ?', Survey::Types::FOR_FOLLOWER)
                   .where('surveys.anonymous_survey_participant_role = ?', AnonymousSurveyParticipant::Roles::DIRECT_REPORT)
                   .joins(:survey)
                   .first!
      question.created_at
    end
  end

  # @return [User]
  #:nocov:
  def self.joel_beasley
    @joel_beasley ||= find_by_email(Rails.configuration.joel_email)
  end
  #:nocov:

  # @return [ActiveRecord::Relation]
  def self.active_recipient
    all
      .joins(:organization)
      .where('organizations.active_since < ?', Time.zone.now)
      .where('users.email NOT IN(SELECT email FROM bounced_emails)')
      .where(leaderbits_sending_enabled: true)
      .where('organizations.leaderbits_sending_enabled IS TRUE')
      .where('users.discarded_at IS NULL')
      .where('users.schedule_id IS NOT NULL')
      .not_currently_in_vacation_mode
  end

  def self.inactive_for_last_14_days
    where('users.created_at < ?', 14.days.ago)
      .yield_self(&method(:no_completed_challenges_recently))
      .yield_self(&method(:no_video_watching))
      .yield_self(&method(:no_entries_posting_recently))
  end

  # @return [String] e.g. "#4a90e2"
  def initials_color
    Rails.cache.fetch("#{__method__}/#{LeaderbitEmployeeMentorship.pluck(:mentor_user_id).uniq.count}") do
      e = '#4a90e2'.dup.paint.palette.tetrad.cycle
      #=> [#4a90e2, #e24adc, #e29c4a, #4ae250]

      sorted_user_ids = LeaderbitEmployeeMentorship.order(mentor_user_id: :asc).pluck(:mentor_user_id).uniq

      index = sorted_user_ids.index(id)
      (index + 1).times do |i|
        val = e.next

        return(val) if index == i
      end
    end
  end

  #NOTE: keep this method in sync with #all_preemptive_active_leaderbits in any of these methods change
  # @return [Leaderbit]
  def upcoming_active_preemptive_leaderbits
    # NOTE:  exclude_already_received_leaderbits is purposely NOT included because
    # Joel request it this way. User may receive preemptive leaderbits multiple times
    # include those that were already sent to user previously
    preemptive_leaderbits
      .yield_self(&method(:only_active_leaderbits))
      .order(position: :asc)
      .yield_self(&method(:exclude_already_received_preemptive_leaderbits))
      .collect(&:leaderbit)
  end

  # @return [Leaderbit]
  def upcoming_active_leaderbits_from_schedule
    schedule
      .leaderbit_schedules
      .yield_self(&method(:only_active_leaderbits))
      .where.not('leaderbits.id' => received_uniq_leaderbit_ids)
      .order(position: :asc)
      .collect(&:leaderbit)
  end

  # NOTE: avoid generate_authentication_token method name because it would conflict with the native gem method
  def generate_unique_authentication_token
    loop do
      token = SecureRandom.hex[0..6]
      if !User.where(authentication_token: token).exists? && !EmailAuthenticationToken.where(authentication_token: token).exists?
        break token
      end
    end
  end

  def self.not_currently_in_vacation_mode
    where('users.id NOT IN(SELECT user_id FROM vacation_modes WHERE starts_at < ? AND ends_at > ?)', Time.zone.now, Time.zone.now)
  end

  def self.with_missing_recent_monthly_progress_report
    where('users.created_at < ?', 1.month.ago)
      .where('users.id NOT IN(SELECT user_id FROM user_sent_emails WHERE type = ? AND created_at > ?)', UserSentMonthlyProgressReport.to_s, 1.month.ago)
  end

  def self.no_completed_challenges_recently(relation)
    relation.where('users.id NOT IN(SELECT user_id FROM leaderbit_logs WHERE status = ? AND updated_at > ?)', LeaderbitLog::Statuses::COMPLETED, 14.days.ago)
  end
  private_class_method :no_completed_challenges_recently

  def self.no_video_watching(relation)
    relation.where('users.id NOT IN(SELECT user_id FROM leaderbit_video_usages WHERE created_at > ?)', 14.days.ago)
  end
  private_class_method :no_video_watching

  def self.no_entries_posting_recently(relation)
    relation.where('users.id NOT IN(SELECT user_id FROM entries WHERE created_at > ?)', 14.days.ago)
  end
  private_class_method :no_entries_posting_recently

  private

  def last_completed_leaderbit_log
    @last_completed_leaderbit_log ||= leaderbit_logs.completed.order(updated_at: :desc).first
  end

  def calculate_momentum
    completed_count = leaderbit_logs
                        .completed
                        .uniq
                        .count

    if completed_count.zero?
      0
    else
      #NOTE: #received_uniq_leaderbit_ids is smart enough to utilize cache with nil argument
      total = received_uniq_leaderbit_ids.count.to_f

      (100 * completed_count / total).to_i.tap do |result|
        # NOTE: do not delete it.
        # that's how we're trying to find the cause for #159692118
        if result > 100
          Rollbar.info("Invalid momentum", momentum: result, user_id: id)
        end
      end
    end
  end

  def trying_to_hide_by_changing_slacking_off_selector
    progress_report_recipient = ProgressReportRecipient.find notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks_was

    AccountabilityMailer
      .with(user: self, recipient_name: progress_report_recipient.user.name, recipient_email: progress_report_recipient.user.email)
      .user_is_trying_to_hide
      .deliver_now
  end

  # this method has to handle 2 use cases:
  # 1) Slacking off PersonA => nil
  # 2) Slacking off PersonB => PerconC
  # in both case it is treated as if user is trying to hide
  def trying_to_hide_by_changing_slacking_off_selector?
    will_save_change_to_notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks? && notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks_was.present?
  end

  #fixes https://www.pivotaltracker.com/story/show/162530308
  def trying_to_hide_by_switching_off_trying_to_hide?
    will_save_change_to_notify_observer_if_im_trying_to_hide? && notify_observer_if_im_trying_to_hide_was == true
  end

  #fixes https://www.pivotaltracker.com/story/show/162530308
  def trying_to_hide_by_switching_off_trying_to_hide
    progress_report_recipients
      .includes(:user)
      .collect(&:user)
      .each do |user_to_notify|
      #TODO-low is there a better way for sending it?
      # this is because we're testing it in capybara-email
      AccountabilityMailer
        .with(user: self, recipient_name: user_to_notify.name, recipient_email: user_to_notify.email)
        .user_is_trying_to_hide
        .yield_self { |mail_message| Rails.env.test? ? mail_message.deliver_now : mail_message.deliver_later }
    end
  end

  #NOTE: in some cases we create(mentee invivation for example) user by just an email
  def validate_name?
    # if you create user from admin interface(or as a team member), then "name" param is provided, it is present or blank - not nil
    !name.nil?
  end

  def only_active_leaderbits(relation)
    relation
      .includes(:leaderbit)
      .where('leaderbits.active' => true)
  end

  def exclude_already_received_preemptive_leaderbits(relation)
    relation.reject do |preemptive_leaderbit|
      last_usl = UserSentScheduledNewLeaderbit
                   .where(user: self, resource_id: preemptive_leaderbit.leaderbit_id)
                   .order(created_at: :desc)
                   .first

      #TODO why do we need it?
      last_usl.present? && preemptive_leaderbit.created_at < last_usl.created_at
    end
  end
end
