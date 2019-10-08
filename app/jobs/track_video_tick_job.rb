# frozen_string_literal: true

class TrackVideoTickJob < ApplicationJob
  queue_as :default

  #NOTE: depending on what type of video is that argument format is different!
  # For regular leaderbit video it is:
  # @param [Hash] data e.g. {"uuid"=>"abcdefgh", "leaderbit_id"=>9, "duration"=>288.491, "video_session_id"=>"uvwG6un6y0LNSCVmPxTEHgtt"}
  # For welcome-video it lacks :leaderbit_id key:
  # @param [Hash] data e.g. {"uuid"=>"abcdefgh", "duration"=>288.491}
  def perform(data)
    data.symbolize_keys!

    user = User.find_by_uuid data.fetch(:uuid)
    return if user.blank?

    if welcome_video_data?(data)
      unless Rails.configuration.welcome_video_duration.round(2) == data.fetch(:duration).round(2)
        Rollbar.scoped(existing_duration: Rails.configuration.welcome_video_duration, new_duration: data.fetch(:duration)) do
          Rollbar.info("Rails.configuration.welcome_video_duration need to be updated")
        end
      end

      user.increment_welcome_video_seconds_watched!
    else
      increment_leaderbit_seconds_counter(data, user)
    end
  end

  private

  def increment_leaderbit_seconds_counter(data, user)
    leaderbit = Leaderbit.find data.fetch(:leaderbit_id)

    video_usage = LeaderbitVideoUsage.find_or_initialize_by(user: user,
                                                            leaderbit: leaderbit,
                                                            video_session_id: data.fetch(:video_session_id))

    unless video_usage.persisted?
      video_usage.seconds_watched = 0
    end

    video_usage.duration = data.fetch(:duration)
    video_usage.increment_seconds_watched!
  end

  def welcome_video_data?(data)
    data.fetch(:leaderbit_id, nil).nil?
  end
end
