# frozen_string_literal: true

class CreateEntry
  include Dry::Transaction

  step :validate
  #TODO we need all these modifier methods to be part of a single db transaction
  step :create_entry

  tee :update_log_status_to_completed
  tee :mark_group_as_seen_by_author
  tee :assign_points
  tee :save_historic_momentum_values
  tee :create_default_boomerang_if_missing

  private

  def validate(input, current_user:)
    leaderbit = Leaderbit.find input.fetch(:leaderbit_id)

    entry = leaderbit.entries.new
    entry.attributes = input.fetch(:entry).without('entry', 'visibility_csv')
    entry.user = current_user
    entry.entry_group = EntryGroup.find_or_create_by!(leaderbit: entry.leaderbit, user: entry.user)

    visibility_csv = input.dig(:entry, :visibility_csv).to_s.split(",")
    if visibility_csv.present?
      entry.visible_to_my_mentors = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::MY_MENTORS)
      entry.visible_to_my_peers = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::MY_PEERS)
      entry.visible_to_community_anonymously = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::LEADERBITS_COMMUNITY_ANONYMOUSLY)
    end

    entry.valid? ? Success(entry) : Failure(entry)
  end

  def create_entry(entry)
    entry.save!

    Success(entry)
  end

  def mark_group_as_seen_by_author(entry)
    UserSeenEntryGroup.find_or_create_by! user: entry.user, entry_group: entry.entry_group

    Success(entry)
  end

  def assign_points(entry)
    # NOTE: keep in mind that user can delete an entry after posting it. Points must be assigned just once to avoid exploiting the system.
    if Entry.where(user: entry.user, leaderbit: entry.leaderbit).count == 1
      Point.create!(user: entry.user,
                    pointable: entry,
                    value: rand(90..96),
                    type: Point::Types::REFLECT_ENTRY)
    end
    Success(entry)
  end

  def save_historic_momentum_values(entry)
    SaveHistoricMomentumValues.call_for_user entry.user

    Success(entry)
  end

  # this method is needed in case when user doesn't adjust default "boomerang" type(which is couple days)
  # so we create this setting manually.
  def create_default_boomerang_if_missing(entry)
    return Success(entry) if BoomerangLeaderbit.where(leaderbit: entry.leaderbit, user: entry.user).exists?

    BoomerangLeaderbit.create!(leaderbit: entry.leaderbit,
                               user: entry.user,
                               type: BoomerangLeaderbit::Types::DEFAULT)

    # it's important to return entry on the last step
    Success(entry)
  end

  def update_log_status_to_completed(entry)
    leaderbit_log = LeaderbitLog
                      .where(user: entry.user, leaderbit: entry.leaderbit)
                      .first

    if leaderbit_log.present? && leaderbit_log.in_progress?
      #NOTE: it doesn't assign points, automatically, that's what #assign_points method is for
      leaderbit_log.completed!
    elsif leaderbit_log.present? && leaderbit_log.completed?
      #all fine, already completed. Move on
    else
      #NOTE: the reason for this code path to exist is because we're still trying to understand what might have caused the original issue
      #
      # in case it ever happens you need to figure out what might have caused it. Referenced story #166769942
      # perhaps there is a direct link to leaderbit somewhere and that's why #start controller action is skipped?
      Rollbar.scoped(user: entry.user.inspect, leaderbit: entry.leaderbit.inspect, leaderbit_log: leaderbit_log.inspect) do
        Rollbar.error("cant find any leaderbitlog to mark as completed")
      end

      # trying to retroactively restore missing points for starting a leaderbit
      leaderbit_log = LeaderbitLog.create_with_in_progress_status_and_assign_points! user: entry.user,
                                                                                     leaderbit: entry.leaderbit
      #NOTE: it doesn't assign points, automatically, that's what #assign_points method is for
      leaderbit_log.completed!
    end
    Success(entry)
  end
end
