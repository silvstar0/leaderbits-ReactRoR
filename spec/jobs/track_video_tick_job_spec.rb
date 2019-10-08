# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrackVideoTickJob, type: :job do
  context 'given leaderbit video' do
    example do
      user = create(:user)
      leaderbit = create(:leaderbit)

      data = { "seconds" => 1.026, "uuid" => user.uuid, "leaderbit_id" => leaderbit.id, "percent" => 0.094, "duration" => 288.491, "video_session_id" => "uvwG6un6y0LNSCVmPxTEHgtt", "action" => "track" }
      expect { described_class.perform_now data }.to change { user.video_usages.last&.seconds_watched }.to(1)

      data = { "seconds" => 2.126, "uuid" => user.uuid, "leaderbit_id" => leaderbit.id, "percent" => 0.094, "duration" => 288.491, "video_session_id" => "uvwG6un6y0LNSCVmPxTEHgtt", "action" => "track" }
      expect { described_class.perform_now data }.to change { user.video_usages.last&.seconds_watched }.from(1).to(2)

      #scrolled back, doesn't matter. User keep watching it so we increment counter
      data = { "seconds" => 0.126, "uuid" => user.uuid, "leaderbit_id" => leaderbit.id, "percent" => 0.094, "duration" => 288.491, "video_session_id" => "uvwG6un6y0LNSCVmPxTEHgtt", "action" => "track" }
      expect { described_class.perform_now data }.to change { user.video_usages.last&.seconds_watched }.from(2).to(3)
    end
  end

  context 'given welcome video' do
    example do
      user = create(:user, welcome_video_seen_seconds: [nil, 0].sample)

      data = { "seconds" => 1.026, "uuid" => user.uuid, "percent" => 0.094, "duration" => 288.491 }
      expect { described_class.perform_now data }.to change { user.reload.welcome_video_seen_seconds }.to(1)

      data = { "seconds" => 2.126, "uuid" => user.uuid, "percent" => 0.094, "duration" => 288.491, "action" => "track" }
      expect { described_class.perform_now data }.to change { user.reload.welcome_video_seen_seconds }.from(1).to(2)

      #scrolled back, doesn't matter. User keep watching it so we increment counter
      data = { "seconds" => 0.126, "uuid" => user.uuid, "percent" => 0.094, "duration" => 288.491, "action" => "track" }
      expect { described_class.perform_now data }.to change { user.reload.welcome_video_seen_seconds }.from(2).to(3)
    end
  end
end
