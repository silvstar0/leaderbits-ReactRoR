# frozen_string_literal: true

module EntriesHelper
  module VisibilityOptions
    MY_MENTORS = 'My Mentors'
    MY_PEERS = 'My Peers'
    LEADERBITS_COMMUNITY_ANONYMOUSLY = 'LeaderBits Community(anonymously)'
  end

  def all_labels
    [
      # always available
      VisibilityOptions::MY_MENTORS,
      VisibilityOptions::LEADERBITS_COMMUNITY_ANONYMOUSLY
    ].yield_self do |labels|
      #only available if they are have a team/company account (not available for individual account)
      labels << VisibilityOptions::MY_PEERS if current_user.organization.enterprise?
      labels
    end
  end

  def selected_labels(entry)
    result = []
    result << VisibilityOptions::MY_MENTORS if entry.visible_to_my_mentors?
    result << VisibilityOptions::MY_PEERS if entry.visible_to_my_peers?
    result << VisibilityOptions::LEADERBITS_COMMUNITY_ANONYMOUSLY if entry.visible_to_community_anonymously?

    result
  end

  def user_action_clarification_in_react_component(entry)
    return '' if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

    "#{entry.user.first_name} #{entry.leaderbit.user_action_title_suffix}"
  end

  def entry_reply_collection_prefilled_content
    return '' if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

    prefix = [
      "\nKeep up the excellent work on these challenges.",
      "\nKeep up the great work.",
      "I'm interested to know, looking forward to your reply.",
      "I can’t wait to see how you grow next week!",
    ].sample

    text1 = "\n\nTalk soon,\n#{current_user.first_name}"
    text2 = "\n\n#{current_user.first_name}"
    prefix + [text1, text1, text2, ""].sample
  end

  def entry_visibility(entry)
    result = []

    if entry.visible_to_my_peers?
      result << "Visible to my peers"
    end

    if entry.visible_to_my_mentors?
      result << "Visible to my mentors"
    end

    if entry.visible_to_community_anonymously?
      result << "LeaderBits Community(anonymously)"
    end

    result.join(", ")
  end

  def boomerang_value_to_title(value)
    BoomerangLeaderbit.boomerang_value_to_title(value)
  end

  def boomerang_options
    [
      ['In a couple days', BoomerangLeaderbit::Types::COUPLE_DAYS],
      ['In 2 weeks', BoomerangLeaderbit::Types::TWO_WEEKS],
      ['Next month', BoomerangLeaderbit::Types::ONE_MONTH],
      ['Never', BoomerangLeaderbit::Types::NEVER]
    ]
  end

  def same_path_attributes_but_without_parameter(attr = nil)
    uri = ::Addressable::URI.parse request.original_fullpath

    uri.query_values ? uri.query_values.without(attr) : {}

    # uri.query_values = uri.query_values.without(attr)
    # binding.pry
    # uri.to_s
  end

  def same_path_but_without_parameter(attr)
    Addressable::URI
      .parse(request.path)
      .tap { |uri| uri.query_values = same_path_attributes_but_without_parameter(attr) }
      .to_s
  end

  def leaderbit_employee_mentors_collection
    LeaderbitEmployeeMentorship
      .joins(:mentor_user)
      .select(:mentor_user_id)
      .distinct(:mentor_user_id)
      .collect { |lem| [lem.mentor_user.name, lem.mentor_user.to_param] }
  end

  def specific_users_collection_on_entries_show
    User
      .where(discarded_at: nil)
      .where.not(schedule_id: nil)
      .where('id IN(SELECT user_id FROM entries)')
      .order(:name)
      .collect { |u| [u.name, u.to_param] }
  end

  def default_mentor_user_selected
    params.dig(:mentor_user_uuid) || ''
  end

  def default_specific_user_selected
    params.dig(:user_uuid) || ''
  end

  def default_specific_leaderbit_selected
    params.dig(:leaderbit_id) || ''
  end

  def default_selected_boomerang_value(entry)
    BoomerangLeaderbit.where(leaderbit: entry.leaderbit, user: current_user).first&.type || BoomerangLeaderbit::Types::DEFAULT
  end

  def display_entry_replies?
    controller_name != 'reports'
  end

  private

  def public_for_all_label
    'Visible to LeaderBits Community'
  end

  def my_organization_leaders_and_leaderbits_organization(user)
    "Visible to Myself + #{user.organization.name.possessive} Leaders + LeaderBits Team"
  end

  def within_my_organization_label(user)
    "Visible to #{user.organization.name.possessive} Community"
  end
end
