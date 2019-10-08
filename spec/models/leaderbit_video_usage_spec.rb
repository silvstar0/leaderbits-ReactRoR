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

require 'rails_helper'

RSpec.describe LeaderbitVideoUsage, type: :model do
  describe '#increment_seconds_watched!' do
    example do
      video_usage = create(:leaderbit_video_usage)
      expect { video_usage.increment_seconds_watched! }.to change { video_usage.reload.seconds_watched }.by(1)
    end
  end

  describe 'user cache invalidation' do
    example do
      video_usage = create(:leaderbit_video_usage)
      user = video_usage.user

      expect { video_usage.increment_seconds_watched! }.to change { user.reload.cache_key_with_version }
    end
  end
end
