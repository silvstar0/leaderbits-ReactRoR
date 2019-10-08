# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbits
#
#  id                       :bigint(8)        not null, primary key
#  name                     :string           not null
#  desc                     :text             not null
#  url                      :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  image                    :string           default("default.png")
#  body                     :text             not null
#  active                   :boolean          default(FALSE)
#  user_action_title_suffix :string           not null
#  entry_prefilled_text     :text
#

class Leaderbit < ApplicationRecord
  DEFAULT_USER_ACTION_TITLE_SUFFIX = 'completed a challenge and brought value to your company.'

  audited

  with_options dependent: :destroy do
    has_many :boomerang_leaderbits
    has_many :entries
    has_many :entry_groups
    has_many :leaderbit_logs #TODO-low rename to just logs?
    has_many :leaderbit_schedules
    has_many :tags, class_name: 'LeaderbitTag'
  end
  has_many :schedules, through: :leaderbit_schedules

  with_options presence: true, allow_nil: false, allow_blank: false do
    validates :name
    validates :desc
    validates :body
    validates :user_action_title_suffix
  end

  validates :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp }, if: -> { url.present? }

  has_one_attached :video_cover, acl: :public

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def to_param
    [id, name.parameterize].join("-")
  end

  def video_frame_id
    "videoFrame#{id}"
  end

  def clean_name
    name.gsub('Challenge: ', '')
  end

  # @return [String] array of strings
  def selected_tag_labels
    tags.pluck(:label)
  end

  def url_with_frame_id
    #NOTE: this workaround is needed so that ANY real vimeo video is displayed
    # for actual leaderbits in production there is permission check that they are visible
    # only on app.leaderbits.io
    if Rails.env.development? || Rails.env.test?
      #could be updated to something else from this random video
      "//player.vimeo.com/video/276013718?portrait=0&player_id=#{video_frame_id}"
    else
      "#{url}?player_id=#{video_frame_id}"
    end
  end
end
