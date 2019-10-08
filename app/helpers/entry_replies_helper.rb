# frozen_string_literal: true

module EntryRepliesHelper
  def entries_index_replies(entry)
    #NOTE: #select & #sort_by because replies are already pre-fetched
    entry
      .replies
      .sort_by(&:id)
      .collect { |reply| reply.to_builder(current_user: current_user, entry: entry).attributes!.symbolize_keys! }
  end

  # method is used frequently on entries#index
  def schedule_name(user)
    Rails.cache.fetch("#{__method__}/ver2/#{user.schedule_id}") do
      name = user.schedule.name.gsub('schedule', 'Schedule') # fix for NTC custom schedule
      name.include?("Schedule") ? name : name + " " + "Schedule"
    end
  end
end
