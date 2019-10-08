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

FactoryBot.define do
  factory :leaderbit_video_usage do
    user
    leaderbit
    video_session_id { SecureRandom.base64.tr('+/=', 'Qrt') }
    seconds_watched { rand(1..360) }
    duration { rand(seconds_watched..seconds_watched + 360) }
  end
end
