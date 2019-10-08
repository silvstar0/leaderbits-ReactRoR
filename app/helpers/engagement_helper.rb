# frozen_string_literal: true

module EngagementHelper
  #TODO add request type module scope
  ALL_PEOPLE = 1
  #NOTE: Fabiana requested "People I mentor"|"Mentors" not to be displayed in case of organization engagement report preview as an admin
  PEOPLE_I_MENTOR = 2

  def request_type_selector_is_visbible?
    return true if @users_i_mentor.present?
    return true if @teams_with_users.present? && @teams_with_users.size >= 1

    #TODO-High also think about one person team
    return false if @teams_with_users.blank?

    # avoid displaying selector in case "All people list" is the same as user's Team list
    _team, users = @teams_with_users.first
    users.collect(&:id).sort != @all_users_in_selector.collect(&:id).sort
  end

  def as_engagement_user(user)
    {
      id: user.id,
      uuid: user.uuid,
      name: user.name,
      email: user.email,
      momentum: number_to_percentage(user.momentum, precision: 0),
      focused: params[:uuid] == user.uuid,
      focusPath: profile_engagement_path(layout: params[:layout], uuid: user.uuid, request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
      focusedPath: profile_engagement_path(layout: params[:layout], status: params[:status], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin])
    }
  end

  def top_people_title
    #raise '@users must be set' if @users.nil?
    #raise '@users is blank' if @users.size.zero?
    return '' if @filtered_users.size == 1

    "Top #{[@filtered_users.size, 5].min} people"
  end

  def users_labels(users)
    users.collect(&:name)
  end

  def users_series(users, leaderbit_logs)
    users.collect { |u| leaderbit_logs.select { |ll| ll.user_id == u.id }.size }
  end

  def by_month_labels(leaderbit_logs)
    leaderbit_logs.group_by { |ll| ll.updated_at.beginning_of_month }.sort_by { |date, _arr| date }.reverse.collect do |date, _leaderbit_logs|
      date.stamp("Oct 2018")
    end.take(10)
  end

  def by_month_labels_series(users, leaderbit_logs)
    #OPTIMIZE
    users.collect do |user|
      leaderbit_logs.group_by { |ll| ll.updated_at.beginning_of_month }.sort_by { |date, _arr| date }.reverse.collect do |_date, leaderbit_logs_at_month|
        leaderbit_logs_at_month.select { |ll| ll.user_id == user.id }.size
      end
    end
  end

  def entries_link
    return 'Entries' if entries_layout?

    link_to("Entries",
            profile_engagement_path(layout: 'entries', status: 'all', uuid: params[:uuid], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
            data: {},
            style: 'color: #4A90E2')
  end

  def value_link
    return 'Value' if value_layout?

    link_to("Value",
            profile_engagement_path(layout: 'value', uuid: params[:uuid], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
            data: {},
            style: 'color: #4A90E2')
  end

  def emails_link
    return 'Emails' if emails_layout?

    link_to("Emails",
            profile_engagement_path(layout: 'emails', status: 'all', uuid: params[:uuid], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
            data: {},
            style: 'color: #4A90E2')
  end

  def all_link
    return 'All' if status_all?

    link_to("All",
            profile_engagement_path(layout: 'entries', status: 'all', uuid: params[:uuid], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
            data: {},
            style: 'color: #4A90E2')
  end

  def unread_link
    return 'Unread' if status_unread?

    link_to("Unread",
            profile_engagement_path(layout: 'entries', status: 'unread', uuid: params[:uuid], request_type: params[:request_type], Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin]),
            data: {},
            style: 'color: #4A90E2')
  end

  def role_names
    {
      AnonymousSurveyParticipant::Roles::DIRECT_REPORT => 'Direct report',
      AnonymousSurveyParticipant::Roles::LEADER_OR_MENTOR => 'Leader or Mentor',
      AnonymousSurveyParticipant::Roles::PEER => 'Peer'
    }
  end

  def role_options
    [
      AnonymousSurveyParticipant::Roles::DIRECT_REPORT,
      AnonymousSurveyParticipant::Roles::LEADER_OR_MENTOR,
      AnonymousSurveyParticipant::Roles::PEER
    ].collect { |key| [role_names.fetch(key), key] }
  end
end
