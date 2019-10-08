# frozen_string_literal: true

# == Schema Information
#
# Table name: entry_replies
#
#  id                      :bigint(8)        not null, primary key
#  user_id                 :bigint(8)        not null
#  entry_id                :bigint(8)        not null
#  content                 :text             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_reply_id         :integer
#  cached_votes_total      :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_votes_down       :integer          default(0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#
# Foreign Keys
#
#  fk_rails_...  (entry_id => entries.id)
#  fk_rails_...  (parent_reply_id => entry_replies.id)
#  fk_rails_...  (user_id => users.id)
#

class EntryReply < ApplicationRecord
  acts_as_votable cacheable_strategy: :update

  include ActionView::Helpers::TextHelper # patched by 'rails_autolink'

  belongs_to :user
  belongs_to :entry, touch: true

  module Colors
    GREY = '#f2f2f2'
    BLUE = 'rgba(74,144,226,0.13)'
    GREEN = 'rgba(80,227,194,0.15)'
  end

  after_create_commit do
    mark_group_as_seen_by_author
    mailer_notify
  end

  after_save :mark_entry_groups_as_unseen_for_everyone_except_replier
  after_save :invalidate_original_entry_authors_cache

  alias_attribute :sender, :user
  validates :content, presence: true, allow_nil: true, allow_blank: false

  include ActionView::Helpers::DateHelper

  #NOTE: entry is passed manually to avoid unnecessary SQL query
  #      it is the same as self#entry
  #@see https://github.com/rails/jbuilder#jbuilder
  def to_builder(current_user:, entry:)
    Jbuilder.new do |json|
      json.extract! self, :id, :user_id, :entry_id, :content, :created_at, :updated_at, :parent_reply_id
      color = if user == entry.user
                Colors::GREY
              elsif user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
                Colors::BLUE
              else
                Colors::GREEN
              end
      json.color color

      json.entry_author user.name_when_entry_author
      json.liked_by_current_user current_user.favorited?(self)
      json.can_like_reply user != current_user
      json.can_reply_to_reply user != current_user
      json.can_edit_reply user == current_user
      json.can_delete_reply user == current_user
      json.current_user current_user.name
      json.display_time "#{time_ago_in_words(created_at)} ago"
      json.reply_content content

      json.entry_group_id entry.entry_group_id

      json.reply_liked_message LikedMessageGenerator
                                 .new(self)
                                 .return_for_user(current_user)
    end
  end

  def parent_entry_reply
    @parent_entry_reply ||= parent_reply_id ? EntryReply.find(parent_reply_id) : nil
  end

  private

  def mailer_notify
    # author replies to himself(his entry or reply on reply). No need to notify him about that
    # upd. what about notifying his mentors? Or marking it(as it works now) as unread makes it acceptable?
    replied_to_yourself = parent_entry_reply.blank? && entry.user == user || parent_entry_reply.present? && parent_entry_reply.user == user
    return if replied_to_yourself

    subject = "#{user.name} Replied to You - #{entry.leaderbit.name}"

    EntryReplyMailer
      .with(entry_reply: self, email_recipient_user: (parent_entry_reply.present? ? parent_entry_reply.user : entry.user), subject: subject)
      .new_reply
      .deliver_now

    return if user == entry.user

    one_mentor_replying_to_another_mentor = parent_entry_reply.present? && parent_entry_reply.user != entry.user
    # or could be rather just a team member
    if one_mentor_replying_to_another_mentor
      subject = "#{user.name} Replied - #{entry.leaderbit.name}"
      EntryReplyMailer
        .with(entry_reply: self, email_recipient_user: entry.user, subject: subject)
        .new_reply
        .deliver_now
    end
  end

  def mark_group_as_seen_by_author
    # "If you mark it as read automatically, you'll need to hide *Mark as Read* button too"
    # upd. is this still relevant?
    UserSeenEntryGroup.find_or_create_by! user: user, entry_group: entry.entry_group
  end

  def mark_entry_groups_as_unseen_for_everyone_except_replier
    UserSeenEntryGroup
      .where.not(user: user)
      .where(entry_group: entry.entry_group)
      .delete_all
  end

  # this is needede to invalidate view fragment cache where we display list of mentors and last time they replied to entry.user
  # cache key is per entry.user
  def invalidate_original_entry_authors_cache
    entry.user.touch
  end
end
