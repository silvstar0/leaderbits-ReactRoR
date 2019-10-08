# frozen_string_literal: true

#:nocov:
namespace :db do
  desc "Dumps the database to db/APP_NAME.dump"
  task dump: :environment do
    raise("Could only be executed in development environment") unless Rails.env.development?

    cmd = nil
    with_config do |app, host, db, user|
      cmd = "pg_dump --host #{host} --username #{user} -Fp --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Anonymizes existing local database"
  task anonymize: :environment do
    raise("Could only be executed in development environment") unless Rails.env.development?

    Rails.logger.silence do
      # if you dont want to affect authentication for some other users after anonymizing, add them here
      except_user_emails = [
        Rails.configuration.nick_email,
        Rails.configuration.joel_email,
        Rails.configuration.fabiana_email,
        Rails.configuration.kerry_email,
        Rails.configuration.yuri_email
      ]

      User.where.not(email: except_user_emails).each do |user|
        attributes = FactoryBot.attributes_for(:user)

        user.attributes = attributes.slice(:email, :name)

        user.authentication_token = Devise.friendly_token
        user.intercom_user_id = Devise.friendly_token
        user.send(:set_uuid_key)

        if user.encrypted_password.present?
          user.password = Devise.friendly_token
        end
        puts user.changes
        puts
        user.save!
      end

      AnonymousSurveyParticipant.all.each do |asp|
        attributes = FactoryBot.attributes_for(:anonymous_survey_participant)
        asp.attributes = attributes.slice(:email, :name, :role)
        asp.uuid = SecureRandom.hex[0..6]

        puts asp.changes
        puts
        asp.save!
      end

      EmailAuthenticationToken.all.each do |eat|
        eat.authentication_token = Devise.friendly_token
        eat.save!
      end

      Organization.where.not(name: official_leaderbits_org_names).each do |organization|
        organization.attributes = FactoryBot.attributes_for(:organization).slice(:name)
        organization.stripe_customer_id = "cus_#{Devise.friendly_token}" if organization.stripe_customer_id.present?

        begin
          organization.save!
        rescue ActiveRecord::RecordInvalid => e
          puts "Could not execute [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
        end
      end

      # Needed because Heroku's hobby-dev PG plan has limit of 10,000 records. And on Mar 2019 this table along is already 50% of that limit. And because this table is basically just glorified logs in postgres.
      HourlyLeaderbitSendingSummary
        .where.not(id: HourlyLeaderbitSendingSummary.pluck(:id).shuffle.take(10))
        .delete_all

      Team.all.each do |team|
        new_attributes = FactoryBot.attributes_for(:team).slice(:name)
        team.attributes = new_attributes
        begin
          team.save!
        rescue ActiveRecord::RecordInvalid => e
          puts "Could not update team name - #{new_attributes} [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
        end
      end
    end
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
     'localhost',
      ActiveRecord::Base.connection_config[:database],
      #TODO
      'nikita'
  end
end

#:nocov:
