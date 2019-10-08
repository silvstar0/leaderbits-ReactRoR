# frozen_string_literal: true

class IntercomContactSubscriber
  def call(_name, _started, _finished, _unique_id, values)
    if /INSERT INTO "users"/.match?(values[:sql])
      values[:binds].select { |b| b.name == 'uuid' }.collect(&:value).each do |uuid|
        Rails.logger.debug "Intercom create for user #{uuid}"

        # approximate after 6fa421fded6f3f49ad80861308f8f6cbfcd8917c it began to fail in specs with:
        # ActiveRecord::StatementInvalid:
        # PG::InFailedSqlTransaction: ERROR:  current transaction is aborted, commands ignored until end of transaction block
        #: SELECT  "users".* FROM "users" WHERE "users"."uuid" = $1 ORDER BY "users"."id" ASC LIMIT $2
        # the goal with this workaround not to fail hard because of this non-critical failure(which must be eventually fixed)

        user = User.where(uuid: uuid).first
        IntercomContactSyncJob.perform_later(user.id) if user.present?
      rescue ActiveRecord::StatementInvalid => e
        Rollbar.scoped(uuid: uuid) do
          Rollbar.error(e)
        end
      end
    end

    if /UPDATE "users"/.match?(values[:sql])
      values[:binds].select { |b| b.name == 'id' }.collect(&:value).each do |user_id|
        Rails.logger.debug "Updating user_id #{user_id}"

        IntercomContactSyncJob.perform_later(user_id)
      end
    end
  end
end

if skip_intercom_sync?
  Rails.logger.debug "Intercom user data sync is disabled"
else
  Rails.logger.debug "Intercom user data sync is enabled"
  ActiveSupport::Notifications.subscribe("sql.active_record", IntercomContactSubscriber.new)
end
