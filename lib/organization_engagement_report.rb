# frozen_string_literal: true

class OrganizationEngagementReport
  include ActionView::Helpers::TextHelper

  def initialize(since_at:, until_at:, organization:)
    @since_at = since_at
    @until_at = until_at

    @organization = organization

    @highly_active_users = []
    @active_users = []
    @not_active_users = []

    @base_users_scope = @organization.users.where('users.created_at < ?', @until_at)

    @all_active_recipient_users = @base_users_scope.active_recipient
    @total_active_recipient_users_count = @all_active_recipient_users.count

    iterate_through_users_and_classify
  end

  def display?
    @total_active_recipient_users_count.positive?
  end

  def completed_challenges_count
    #NOTE: it is important to check all users here, not just active recipients because
    # they may go into vacation and we still need to display their completed challenges
    # see commit 8fb0cb9f74be139c834eb481c14bac7abc98b9f0 and #166874114 story

    LeaderbitLog
      .completed
      .where(user_id: @base_users_scope.collect(&:id))
      .where('updated_at >= ? AND updated_at < ?', @since_at, @until_at)
      .count
  end

  #the reason why we have this special handling is because with 2 blank pie sections(and long labels) they overlap and don't look good
  def highly_active_users_label
    if @highly_active_users.count.positive?
      return <<~HTML
        <span style="display: inline-block; width: 53px">#{highly_active_users_perc.round(1)}%</span>
        <span style="display: inline-block; text-align: center; width: 120px">
          <strong style="text-decoration: underline">
            #{ActionController::Base.helpers.link_to 'Highly Active', Rails.application.routes.url_helpers.admin_users_path(user_ids: @highly_active_users.collect(&:id).join(','))}
          </strong>
        </span>
        <span>#{pluralize(@highly_active_users.count, 'person', 'people')}</span>
      HTML
    end

    ''
  end

  def active_users_label
    if @active_users.count.positive?
      return <<~HTML
        <span style="display: inline-block; width: 53px">#{active_users_perc.round(1)}%</span>
        <span style="display: inline-block; text-align: center; width: 120px">
          <strong style="text-decoration: underline">
            #{ActionController::Base.helpers.link_to 'Active', Rails.application.routes.url_helpers.admin_users_path(user_ids: @active_users.collect(&:id).join(','))}
          </strong>
        </span>
        <span>#{pluralize(@active_users.count, 'person', 'people')}</span>
      HTML
    end

    ''
  end

  def not_active_users_label
    if @not_active_users.count.positive?
      return <<~HTML
        <span style="display: inline-block; width: 53px">#{not_active_users_perc.round(1)}%</span>
        <span style="display: inline-block; text-align: center; width: 120px">
          <strong style="text-decoration: underline">
            #{ActionController::Base.helpers.link_to 'Not Active', Rails.application.routes.url_helpers.admin_users_path(user_ids: @not_active_users.collect(&:id).join(','))}
          </strong>
        </span>
        <span>#{pluralize(@not_active_users.count, 'person', 'people')}</span>
      HTML
    end

    ''
  end

  def highly_active_users_perc
    100.0 * @highly_active_users.count / @total_active_recipient_users_count
  end

  def active_users_perc
    100.0 * @active_users.count / @total_active_recipient_users_count
  end

  def not_active_users_perc
    100.0 * @not_active_users.count / @total_active_recipient_users_count
  end

  private

  def iterate_through_users_and_classify
    @organization.users.active_recipient.where('users.created_at < ?', @until_at).each do |user|
      actual = user.activity_type(@since_at, @until_at)
      case actual
      when :highly_active
        @highly_active_users << user
      when :active
        @active_users << user
      when :not_active
        @not_active_users << user
      else
        raise("can not interpret #{actual}")
      end
    end
  end
end
