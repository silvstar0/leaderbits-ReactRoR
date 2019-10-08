# frozen_string_literal: true

module AdminHelper
  module PeriodOptions
    ALL_TIME = 'All Time'
    #WEEK_TO_DATE = 'Week to date'
    #PAST_WEEK = 'Past week'
    MONTH_TO_DATE = 'Month to date'
    QUARTER_TO_DATE = 'Quarter to date'
    PAST_QUARTER = 'Past quarter'
    PAST_MONTH = 'Past month'

    ALL = [
      ALL_TIME,
      #WEEK_TO_DATE,
      #PAST_WEEK,
      MONTH_TO_DATE,
      PAST_MONTH,
      QUARTER_TO_DATE,
      PAST_QUARTER
    ].freeze
  end

  def period_options
    options_for_select( PeriodOptions::ALL.collect { |str| ["Period: #{str}", str.parameterize] }, params[:period])
  end

  def activity_date_range(organization)
    period = params[:period] || PeriodOptions::ALL_TIME.dup.parameterize

    #week_start_day = :sunday
    if period == PeriodOptions::ALL_TIME.dup.parameterize
      # this workaround covers use cases when user is switched from one organization to another
      start_date = [organization.created_at, organization.users.collect(&:created_at)].flatten.min
      end_date = Time.now
      # elsif period == PeriodOptions::WEEK_TO_DATE.dup.parameterize
      #   start_date = Time.now.beginning_of_week(week_start_day)
      #   end_date = Time.now
      # elsif period == PeriodOptions::PAST_WEEK.dup.parameterize
      #   start_date = 1.week.until(Time.now.beginning_of_week(week_start_day))
      #   end_date = 1.second.until(Time.now.beginning_of_week(week_start_day))
    elsif period == PeriodOptions::MONTH_TO_DATE.dup.parameterize
      start_date = Time.now.beginning_of_month
      end_date = Time.now
    elsif period == PeriodOptions::QUARTER_TO_DATE.dup.parameterize
      start_date = Time.now.beginning_of_quarter
      end_date = Time.now
    elsif period == PeriodOptions::PAST_QUARTER.dup.parameterize
      start_date = 3.months.until(Time.now.beginning_of_quarter)
      end_date = 1.second.until(Time.now.beginning_of_quarter)
    elsif period == PeriodOptions::PAST_MONTH.dup.parameterize
      start_date = 1.month.until(Time.now.beginning_of_month)
      end_date = 1.second.until(Time.now.beginning_of_month)
    end
    start_date..end_date
  end

  # @param [LeaderbitEmployeeMentorship] all_leaderbit_employee_mentorships
  def leaderbit_employee_mentors_initials(for_user_id, all_leaderbit_employee_mentorships)
    all_leaderbit_employee_mentorships
      .select { |lem| lem.mentee_user_id == for_user_id }
      .collect { |lem| content_tag_for(:a, lem.mentor_user, title: lem.mentor_user.name, style: "color: #{lem.mentor_user.initials_color}") { lem.mentor_user.name_initials } }.join(", ").html_safe
  end

  def mentors_in_organization_as_initials(organization)
    cache_key = "#{__method__}/#{LeaderbitEmployeeMentorship.select(:created_at).order(created_at: :asc).last.created_at}/#{organization.id}"

    Rails.cache.fetch(cache_key) do
      all_mentor_user_ids_in_organization = LeaderbitEmployeeMentorship
                                              .joins(mentee_user: :organization)
                                              .where('organizations.id = ?', organization.id)
                                              .pluck(:mentor_user_id)
                                              .uniq

      all_mentor_user_ids_in_organization
        .collect { |user_id| User.find(user_id) }
        .collect { |mentor_user| content_tag_for(:font, mentor_user, title: mentor_user.name, style: "color: #{mentor_user.initials_color}") { mentor_user.name_initials } }
        .join(', ')
    end
  end

  def auditable_sti_tolerant_type(audit)
    # just "audit.auditable.class.to_s" doesn't work because:
    ##ActiveRecord::SubclassNotFound: Invalid single-table inheritance type: OrganizationSentProgressDump is not a subclass of UserSentEmail

    %(#{UserSentEmail.find(audit.auditable_id).class}(##{audit.auditable_id}))
  end

  def audit_menu_title
    since_time = current_user.last_seen_audit_created_at || 1.year.ago #Date.parse('Mar 04 2019')
    #TODO abstract and DRY fitlered(noisy) auditable_type
    unseen_count = Audited::Audit.where.not(auditable_type: LeaderbitEmployeeMentorship.to_s).where('created_at > ?', since_time).count
    if unseen_count.zero?
      "Audit"
    else
      %(Audit <span style="border-radius: 10%" class="badge">#{unseen_count}</span>).html_safe
    end
  end

  def admin_user_item_class(user)
    'discarded-list-item' unless user.active_scheduled_leaderbits_receiver?
  end

  def admin_user_item_tooltip(user)
    'Not an active scheduled LeaderBits receiver' unless user.active_scheduled_leaderbits_receiver?
  end

  def admin_leaderbit_item_class(leaderbit)
    'discarded-list-item' unless leaderbit.active?
  end

  def admin_leaderbit_item_tooltip(leaderbit)
    'Not an active LeaderBit' unless leaderbit.active?
  end

  def introducing_hint(organization)
    return '' if organization.persisted?

    simple_format <<~HEREDOC.strip_heredoc
          HINT: You may use some of these messages from previous introductions:
      <blockquote> Hi Team, It's great to have you on board!

      LeaderBits is a way for me to resource you with leadership content. The system sends out small bits of leadership in short 2-5min videos over time.

      It's great to have you on board! I've gone ahead and setup the order for your LeaderBits. Below is your first LeaderBit challenge. Get excited!

      Let's setup a quick call next week so I can get to know you and what you are working on. This way I can make sure the order of the challenges bring you the most value.

      Talk soon,
      Joel
      P.S. Please whitelist team@leaderbits.io to ensure you receive the LeaderBits.</blockquote>
    HEREDOC
  end

  def order_by_link(name, attribute = nil)
    attribute ||= name.parameterize.underscore

    link_to params.to_unsafe_h.merge(order: attribute, direction: order_by_direction(attribute) == 'asc' ? 'desc' : 'asc') do
      raw name +
        content_tag(:i, nil, class: "fa fa-sort#{"-#{order_by_direction(attribute)}" unless order_by_direction(attribute).blank?}")
    end
  end

  def humanized_attribute_label(attribute_name)
    attribute_name
      .to_s
      .humanize
      .titleize
      .gsub(' As String', '')
      .gsub('Url', 'URL')
      .gsub('Actual Image', 'Image')
      .gsub('Humanize ', '')
      .gsub('Humanized ', '')
      .yield_self do |result|
      #Leaderbits Sending Enabled => No/Yes
      #Whole Organization Leaderbits Sending Enabled => No/Yes
      result.gsub(' Enabled', '')
    end
  end

  def attribute_value(model, attribute)
    value = model.send(attribute)

    if value == true
      return "Yes"
    end

    if value == false
      return "No"
    end

    if value.is_a?(ActiveSupport::TimeWithZone)
      return %(<time class="timeago" datetime="#{value.getutc.iso8601}" />).html_safe
    end

    if attribute == :logo
      return logo(model)
    end

    return nil if value.nil?

    if value.is_a?(ActiveRecord::Base)
      link_to belongs_to_name(value), [:admin, value]

    elsif value.is_a?(Array)
      value.join(', ')
    else
      value.is_a?(String) ? value.gsub('_onboarding_step', '') : value
    end
  end

  # def has_many_attribute?(model, attribute)
  #   model.class.reflect_on_association(attribute) && !model.send(attribute).is_a?(ActiveRecord::Base)
  # end

  def belongs_to_name(model)
    model.attributes['name'] || "#{model.class.name.humanize.titleize} ##{model.id}"
  end

  def users_with_schedule(schedule)
    if current_user.system_admin?
      User
        .where(schedule: schedule)
        .group('organization_id, id')
        .order(id: :desc)
    elsif current_user.leaderbits_employee_with_access_to_any_organization?
      organization_ids = current_user.leaderbits_employee_with_access_to_organizations.collect(&:id)

      User
        .where(organization: organization_ids)
        .where(schedule: schedule)
        .group('organization_id, id')
        .order(id: :desc)
    else
      raise
    end
  end

  def organizations_collection(for_user:)
    if for_user.system_admin?
      Organization
        .kept
        .order(name: :asc)
        .pluck(:name, :id)
    elsif for_user.leaderbits_employee_with_access_to_any_organization?
      for_user
        .leaderbits_employee_with_access_to_organizations
        .collect { |organization| [organization.name, organization.id] }
    else
      raise
    end
  end

  def user_accessible_leaderbits_for_manual_sending(user)
    return [] if user.schedule.blank?

    user
      .schedule
      .leaderbits
      .active
      .order(created_at: :desc)
  end

  def user_accessible_leaderbits_for_preemptive_queue(user)
    #TODO perhaps condition should be more broad here? Not limited to user's schedule
    exclude_leaderbit_ids = user.preemptive_leaderbits.pluck(:leaderbit_id)

    user_accessible_leaderbits_for_manual_sending(user)
      .reject { |leaderbit| exclude_leaderbit_ids.include?(leaderbit.id) }
  end

  def leaderbits_for_adding_to_schedule
    Leaderbit.active.where('id NOT IN(SELECT leaderbit_id FROM leaderbit_schedules WHERE schedule_id = ?)', @schedule.id)
  end

  # @return [String]
  def welcome_video_time_watched(user)
    i = user.welcome_video_seen_seconds
    #TODO-low figure out actual type, need migration
    return i if i.nil? || i.zero?

    #TODO "30 secs (1 minute)" fix for < 1 minute

    %(#{i} secs<br>(#{distance_of_time_in_words Time.now, i.seconds.from_now})).html_safe
  end

  def leader_users(in_team)
    TeamMember
      .includes(:user)
      .where(team: in_team, role: TeamMember::Roles::LEADER)
      .collect(&:user)
  end

  def member_users(in_team)
    TeamMember
      .includes(:user)
      .where(team: in_team, role: TeamMember::Roles::MEMBER)
      .collect(&:user)
  end
end
