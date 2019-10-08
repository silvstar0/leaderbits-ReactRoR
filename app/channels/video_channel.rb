# frozen_string_literal: true

class VideoChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'messages'
  end

  def unsubscribed
    Rails.logger.debug __method__.to_s
  end

  # @param [Hash] data e.g. {"seconds"=>27.026, "uuid"=>"abcdefgh", leaderbit_id"=>9, percent"=>0.094, "duration"=>288.491, "video_session_id"=>"uvwG6un6y0LNSCVmPxTEHgtt", "action"=>"track"
  def track(data)
    Rails.logger.debug "#{__method__} #{data.inspect}"

    # NOTE: we're purposely ignoring :seconds key here before it is not reliable and we only track actual seconds-ticks/jobs
    params = data
               .symbolize_keys
               .slice(:leaderbit_id, :video_session_id, :duration)
               .merge(uuid: current_user)

    TrackVideoTickJob.perform_later params
  end
end
