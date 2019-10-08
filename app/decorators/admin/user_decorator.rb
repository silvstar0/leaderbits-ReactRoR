# frozen_string_literal: true

class PaginatingDecorator < Draper::CollectionDecorator
  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset
end

module Admin
  class UserDecorator < ApplicationDecorator
    include ActionView::Helpers::UrlHelper

    delegate_all
    # needed by dom_id
    decorates :user

    # needed by will_paginate
    delegate :current_page, :per_page, :offset, :total_entries, :total_pages

    # @return [Boolean]
    def account_leaderbits_sending_enabled
      organization.leaderbits_sending_enabled?
    end

    # @return [String] html_safe string
    def humanized_roles
      Rails.cache.fetch "#{__method__}/#{cache_key_with_version}/v4" do
        result = TeamMember.includes(:team).where(user: self).collect do |tm|
          "team #{tm.role} in #{link_to tm.team.name, "/admin/teams/#{tm.team_id}"}"
        end

        mentee_links = []
        mentor_links = []
        OrganizationalMentorship
          .where('mentor_user_id = ? OR mentee_user_id = ?', id, id)
          .includes(:mentee_user, :mentor_user)
          .each do |um|
          if um.mentor_user == self
            mentor_links << link_to(um.mentee_user.first_name, "/admin/users/#{um.mentee_user.uuid}")
          else
            mentee_links << link_to(um.mentor_user.first_name, "/admin/users/#{um.mentor_user.uuid}")
          end
        end
        if mentor_links.present?
          result = (result << "Mentor of #{mentor_links.join(', ')}").flatten.compact
        end
        if mentee_links.present?
          result = (result << "Mentee of #{mentee_links.join(', ')}").flatten.compact
        end

        employee_links = []
        LeaderbitsEmployee.where(user: self).includes(:organization).each do |le|
          employee_links << link_to(le.organization.name, "/admin/organizations/#{le.organization_id}")
        end

        if employee_links.present?
          result << "LeaderBits employee in #{employee_links.join(', ')}"
        end

        #TODO-low inline progress report receivers as well
        progress_report_result = ProgressReportRecipient
                                   .where('added_by_user_id = ? OR user_id = ?', id, id)
                                   .includes(:added_by_user, :user)
                                   .collect do |um|
          um.user == self ? "Progress report receiver from #{link_to um.added_by_user.first_name, "/admin/users/#{um.added_by_user.uuid}"}" : "Progress report shared with #{link_to um.user.first_name, "/admin/users/#{um.user.uuid}"}"
        end
        result = (result << progress_report_result).flatten.compact
        result << "C-Level" if c_level?

        return '<ul><li>no role</li></ul>'.html_safe if result.blank?

        "<ul>#{result.map { |str| "<li>#{str}</li>" }.join('')}</ul>".html_safe
      end
    end

    def last_sign_in
      last_sign_in_at ? last_sign_in_at.stamp('Mon 29 Sep 23:59') : ''
    end

    def momentum_as_string
      "#{momentum}%"
    end

    # @return [Leaderbit]
    def last_challenge_completed
      last_completed_leaderbit_as_string
    end

    include ActionView::Helpers::DateHelper

    # @return [String]
    def challenges_completed_for_default_schedule
      leaderbit_logs.completed.count
    end

    # @return [String]
    def challenges_sent_for_default_schedule
      #NOTE: uniq is needed because for old users/record manually sent leaderbits have user_sent_scheduled_new_leaderbit type
      #      because separate manually sent type wasn't introduced from the very beginning
      @challenges_sent_for_default_schedule ||= received_uniq_leaderbit_ids.count
    end

    # @return [String]
    def challenges_unsent_for_default_schedule
      schedule.leaderbits.active.count - challenges_sent_for_default_schedule
    end

    # @return [String]
    def challenges_sent_but_not_completed
      received_uniq_leaderbit_ids.count - leaderbit_logs.completed.count
    end

    # @return [String]
    def total_time_watched
      i = video_usages.sum(:seconds_watched)
      return i if i.zero?

      #TODO "30 secs (1 minute)" fix for < 1 minute

      %(#{i} secs<br>(#{distance_of_time_in_words Time.now, i.seconds.from_now})).html_safe
    end

    # @return [String]
    def challenges_watched_but_not_completed
      (video_usages.pluck(:leaderbit_id) - leaderbit_logs.completed.pluck(:leaderbit_id)).size
    end

    private

    def default_schedule_leaderbit_ids
      @default_schedule_leaderbit_ids ||= schedule.leaderbits.active.pluck(:id)
    end
  end
end
