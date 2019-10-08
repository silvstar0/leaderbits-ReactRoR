# frozen_string_literal: true

Kernel.class_eval do
  def intercom_client
    @intercom_client ||= begin
      token = ENV.fetch('INTERCOM_ACCESS_TOKEN', nil)
      Intercom::Client.new(token: token)
    end
  end

  def slack_notify(message)
    webhook_url = ENV['SLACK_SUPPORT_ROOM_WEBHOOK_URL']
    return if webhook_url.blank?

    notifier = Slack::Notifier.new webhook_url
    notifier.ping message
  end

  # sort criteria for team members.
  # Sort in descending order by momentum and total points
  def by_momentum
    ->(user1, user2) { [user2.momentum, user2.total_points] <=> [user1.momentum, user1.total_points] }
  end

  # as of Dec 2018 this gives users of there orgs some additional admin features
  def official_leaderbits_org_names
    ['LeaderBits', 'Modern CTO', 'Logic17']
  end

  # @return [String] array of strings
  def all_global_tag_labels
    query = <<-SQL.squish
      SELECT "question_tags"."label" FROM "question_tags"
        UNION SELECT "leaderbit_tags"."label" FROM "leaderbit_tags"
        ORDER BY "label" ASC
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten.uniq
  end
end
