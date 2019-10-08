# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_video_usages
#
#  id                                                                                                                                                              :bigint(8)        not null, primary key
#  video_session_id(uniq identifier that is generated per page view. In periodic AJAX requests we are incrementing #seconds_watched by providing this identifier.) :string           not null
#  seconds_watched                                                                                                                                                 :integer          not null
#  user_id                                                                                                                                                         :bigint(8)        not null
#  leaderbit_id                                                                                                                                                    :bigint(8)        not null
#  created_at                                                                                                                                                      :datetime         not null
#  duration                                                                                                                                                        :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

class LeaderbitVideoUsage < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :leaderbit

  validates :video_session_id, presence: true, allow_nil: false, allow_blank: false
  validates :video_session_id, uniqueness: { scope: :user }, if: -> { video_session_id_changed? }

  def increment_seconds_watched!
    self.seconds_watched = seconds_watched + 1
    #NOTE: do not remove rescuing. In case it triggers we don't need to retry hundreds of failed sidekiq jobs
    begin
      save!
    rescue StandardError => e
      Rollbar.scoped(video_session_id: video_session_id) do
        Rollbar.error(e)
      end
    end
  end
end
