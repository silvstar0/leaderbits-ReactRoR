# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id                                                                                                                          :bigint(8)        not null, primary key
#  leaderbit_id                                                                                                                :bigint(8)        not null
#  content                                                                                                                     :text             not null
#  user_id                                                                                                                     :bigint(8)        not null
#  created_at                                                                                                                  :datetime         not null
#  updated_at                                                                                                                  :datetime         not null
#  cached_votes_total                                                                                                          :integer          default(0)
#  cached_votes_score                                                                                                          :integer          default(0)
#  cached_votes_up                                                                                                             :integer          default(0)
#  cached_votes_down                                                                                                           :integer          default(0)
#  cached_weighted_score                                                                                                       :integer          default(0)
#  cached_weighted_total                                                                                                       :integer          default(0)
#  cached_weighted_average                                                                                                     :float            default(0.0)
#  entry_group_id                                                                                                              :bigint(8)        not null
#  content_updated_at(needed to reliably separate actual content update time from nested :touch => true ActiveRecord triggers) :datetime
#  visible_to_my_mentors                                                                                                       :boolean          default(FALSE), not null
#  visible_to_my_peers                                                                                                         :boolean          default(FALSE), not null
#  visible_to_community_anonymously                                                                                            :boolean          default(FALSE), not null
#  discarded_at                                                                                                                :datetime
#
# Foreign Keys
#
#  fk_rails_...  (entry_group_id => entry_groups.id)
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

class Entry < ApplicationRecord
  include Discard::Model

  belongs_to :leaderbit

  # not need to :touch user because it is cached as composite key anyway(cache [user, entry])
  belongs_to :user

  belongs_to :entry_group
  with_options dependent: :destroy do
    has_many :points, as: :pointable
    has_many :replies, class_name: 'EntryReply'
  end

  acts_as_votable cacheable_strategy: :update

  after_create_commit do
    # the update is dependent on time and will check time + comments to make sure it can be live.
    check_if_need_to_notify_mentor_or_team_leader
  end

  #TODO do we still need to keep this? conditions like ".where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)')" should cover it
  #TODO what to do with leaderbit log if entry is deleted
  # this method is unreachable anymore because entries are rather soft-deleted instead
  # after_destroy_commit do
  #   check_if_need_to_delete_group
  # end

  validates :content, length: { minimum: 2 }
  validate do
    if leaderbit.entry_prefilled_text.present? && content.squish == leaderbit.entry_prefilled_text.squish
      errors.add(:content, :invalid)
    end
  end

  validate do
    if entry_group.present? && entry_group.persisted?
      raise(ArgumentError, "entry & entry_group has to belong to the same user") unless user == entry_group.user

      #NOTE: why entries have #leaderbit_id in the first place if entry_group already have that?
      # historically that's how it was in first place.
      # Why don't we remove this data duplication/non-normalized form? We probably can. But at first sight it doesn't seem trivial and some queries would become more complicated(and slow?)
      raise(ArgumentError, "entry & entry_group has to belong to the same leaderbit") unless leaderbit == entry_group.leaderbit
    end
  end

  after_validation :touch_content_updated_at, if: ->(obj){ obj.content_changed? }

  def set_default_entry_visibility
    latest_entry = user.entries.order(created_at: :desc).first
    if latest_entry.present?
      self.visible_to_my_mentors = latest_entry.visible_to_my_mentors
      self.visible_to_my_peers = latest_entry.visible_to_my_peers
      self.visible_to_community_anonymously = latest_entry.visible_to_community_anonymously
    else
      self.visible_to_my_mentors = true
      self.visible_to_my_peers = true
    end
  end

  def likes_score
    cached_votes_score
  end

  # this method is needed for display time of entry creation/modification
  # Why can't we just rely on #updated_at
  # updated_at is used heavily for cache and cache invalidation. Lots of events may trigger it and we want to keep it simple and separate.
  # @return [ActiveSupport:::TimeWithZone]
  def display_time
    content_updated_at || created_at
  end

  # @return [Array]
  def prefilled_replies(current_user)
    return [] if current_user == user
    return [] if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

    #TODO-low for more advanced use cases you need to implement some additional logic

    [
      "Good work this week, #{user.first_name}.",
      "Excellent, #{user.first_name}!",
      "Well done #{user.first_name}!",
      "Brilliant job #{user.first_name}!",
      "Excellent entry this week, #{user.first_name}!",
      "Outstanding work #{user.first_name}!",
      "#{user.first_name}! This is truly above and beyond.",
      "This is superb #{user.first_name}!",
      "#{user.first_name} you set a high bar with this one.",
      "This showcases you are a role model and leader in our organization.",
      "Excellent entry #{user.first_name}!",
      "Excellent #{user.first_name}!",
      "Yesssssssss.",
      "#{user.first_name}! Excellent entry.",
      "Excellent entry #{user.first_name}! A+ Love it!",
      "Fantastic entry!",
      "#{user.first_name}! You did amazing on this entry, wow!",
      "Excellent response to this challenge #{user.first_name}.",
      "Great Job on this #{user.first_name}."
    ].shuffle.take(6).yield_self do |result|
      entries_count = user.entries.kept.count
      if entries_count == 1
        result.prepend("#{user.first_name}! Great first entry!")
        result.prepend("Welcome to LeaderBits #{user.first_name}!")
        result.prepend("Welcome to LeaderBits #{user.first_name}! Great first entry!")
      elsif entries_count > 1
        result.prepend("#{user.first_name}, you did it again! Excellent entry!")
      end

      result
    end
  end

  private

  #@see #display_time
  def touch_content_updated_at
    return unless persisted?

    self.content_updated_at = send(:current_time_from_proper_timezone)
  end

  #TODO do we still need to keep this? conditions like ".where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)')" should cover it
  # this method is unreachable anymore because entries are rather soft-deleted instead
  # def check_if_need_to_delete_group
  #   #cleaning up user_seen_entry_groups first otherwise entry_group couldn't be destroyed(referenced checks)
  #   UserSeenEntryGroup.where(user: user, entry_group: entry_group).destroy_all
  #
  #   entry_group.destroy! if entry_group.present? && entry_group.entries.count.zero?
  # end

  # this callback/method is needed because certain mentors are created with explicit leaderbits_sending_enabled=false status,
  # therefore they do not receive leaderbits with magic links therefore they can not sign in.
  # That is the first relevant email notification with magic link that will sign them in for the first time.
  def check_if_need_to_notify_mentor_or_team_leader
    member_in_team_ids = TeamMember.where(user: user, role: TeamMember::Roles::MEMBER).pluck(:team_id)

    team_leader_user_ids = TeamMember.joins(:user).where('users.leaderbits_sending_enabled IS FALSE').where(team: member_in_team_ids, role: TeamMember::Roles::LEADER).pluck(:user_id) || [-1]

    unnotified_users = user
                         .organization
                         .users
                         .where(leaderbits_sending_enabled: false)
                         .where('users.id NOT IN(SELECT user_id FROM user_sent_emails WHERE type = ?)', UserSentFirstEntryForReviewForNonActiveRecipient.to_s)
                         .where('users.id IN(SELECT mentor_user_id FROM organizational_mentorships WHERE mentee_user_id = ?) OR users.id IN(?)', user_id, team_leader_user_ids)

    unnotified_users.each do |user|
      EntryMailer
        .with(entry: self, recipient_user: user)
        .first_entry_for_non_active_leaderbits_recipient_user_to_review
        .yield_self { |mail_message| Rails.env.test? || Rails.env.development? ? mail_message.deliver_now : mail_message.deliver_later }

      UserSentFirstEntryForReviewForNonActiveRecipient.create! user: user
    rescue StandardError => e
      logger.error "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"

      Rollbar.scoped(user: user.inspect, entry: entry.inspect) do
        Rollbar.error(e)
      end
    end
  end
end
