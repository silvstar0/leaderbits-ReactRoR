# frozen_string_literal: true

module DateTimeHelpers
  #        July 2018
  # Su Mo Tu We Th Fr Sa
  #  1  2  3  4  5  6  7
  #  8  9 10 11 12 13 14
  # 15 16 17 18 19 20 21
  # 22 23 24 25 26 27 28
  # 29 30 31

  def monday_time(options = {})
    parse_time_in_tz "July 23 2018", options
  end

  def tuesday_time(options = {})
    parse_time_in_tz "July 24 2018", options
  end

  def friday_time(options)
    parse_time_in_tz "July 27 2018", options
  end

  def saturday_time(options)
    parse_time_in_tz "July 28 2018", options
  end

  private

  def parse_time_in_tz(readable_date, options)
    tz_name = options.fetch(:tz_name) { ActiveSupport::TimeZone.all.sample.name }
    hour = options.fetch(:hour) { rand(0..23) }
    hour = hour.to_s.rjust(2, "0")

    minute = options.fetch(:minute) { '00' }.to_s

    tz = ActiveSupport::TimeZone[tz_name] || raise
    Time.use_zone(tz) do
      Time.zone.parse("#{readable_date} #{hour}:#{minute}:00")
    end
  end
end

RSpec.configure do |config|
  config.include DateTimeHelpers
end
