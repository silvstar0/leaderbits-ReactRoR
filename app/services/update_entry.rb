# frozen_string_literal: true

class UpdateEntry
  include Dry::Transaction

  step :validate
  step :update
  step :create_default_boomerang_if_missing

  private

  def validate(input)
    entry = Entry.find input.fetch(:id)

    entry.attributes = input.fetch(:entry).without('entry', 'visibility_csv')

    entry.visible_to_my_mentors = false
    entry.visible_to_my_peers = false
    entry.visible_to_community_anonymously = false

    visibility_csv = input.dig(:entry, :visibility_csv).to_s.split(",")
    if visibility_csv.present?
      entry.visible_to_my_mentors = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::MY_MENTORS)
      entry.visible_to_my_peers = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::MY_PEERS)
      entry.visible_to_community_anonymously = true if visibility_csv.include?(EntriesHelper::VisibilityOptions::LEADERBITS_COMMUNITY_ANONYMOUSLY)
    end

    entry.valid? ? Success(entry) : Failure(entry)
  end

  def update(entry)
    entry.save!

    Success(entry)
  end

  # this method is needed in case when user doesn't adjust default "boomerang" type(which is couple days)
  # so we create this setting manually.
  def create_default_boomerang_if_missing(entry)
    unless BoomerangLeaderbit.where(leaderbit: entry.leaderbit, user: entry.user).exists?
      BoomerangLeaderbit.create!(leaderbit: entry.leaderbit,
                                 user: entry.user,
                                 type: BoomerangLeaderbit::Types::DEFAULT)
    end

    Success(entry)
  end
end
