# frozen_string_literal: true

require_relative 'boot'

require "rails"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# it is intentionally extracted into constant to make it work for capybara & capybara-email
# NOTE: it is here and not in constants.rb because in Rails environment is loaded before initializer
SERVER_PORT_IN_TEST_ENV = 4000

require_relative "../lib/expired_auth_link_middleware"

module Leader
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.cloudfront_host = ENV.fetch('CLOUDFRONT_HOST') { raise 'missing CLOUDFRONT_HOST' if Rails.env.staging? || Rails.env.production? }

    config.mailer_default_from = 'LeaderBits Team <team@leaderbits.io>'

    config.achievements = ActiveSupport::OrderedOptions.new
    # NOTE: must be integer!
    # upd. still only integer? why was that in the first place?
    config.achievements.first_completed_challenge__on_leaderbits_show = 1.to_s
    config.achievements.first_completed_challenge__on_dashboard = 2.to_s

    #What this content yield block does is setting explicitely mail content preview in OSX Mail apps(perhaps some others too)
    # you may need it if default(first couple words) content doesn't clearly represent what this email is about and wouldn't look nice in preview.
    config.mailer_pre_header = 'mailer-pre-header'

    #css
    config.add_to_next_up_select_dom_id = 'add-to-next-up-select'
    config.send_leaderbit_manually_select_dom_id = 'send-leaderbit-manually-select'


    config.display_first_completed_challenge_in_dashboard_session_key = 'fccsk'
    config.custom_title_on_reset_password_page = 'ctorpp'

    config.user_sent_email_params_url = 'url'

    #TODO rename because it is not clear enough
    config.minimum_number_of_completed_surveys_to_display = 2

    # in seconds
    # this number is provided by vimeo js player(see onPlayProgress)
    # it didn't ever change(as of Mar 2019) but in case existing welcome vimeo video is update you'll be notified about new duration.
    # This will be needed to calculate #welcome_video_seen_percentage
    # #NOTE: this number keep randomly updating - 131.968, 131.965.. strange. Rounding as a workaround
    config.welcome_video_duration = 131.965

    config.welcome_video_url = 'https://player.vimeo.com/video/280627699'

    # it is used for checking whether we need to give current_user some additional admin abilities
    config.joel_email = 'jbeasley6651@gmail.com'

    config.nick_email = 'nfedyashev@gmail.com'

    config.courtney_email = 'courtney@moderncto.io'

    config.fabiana_email = 'fabiana@leaderbits.io'

    config.allison_email = 'allison@leaderbits.io'

    # copywriter
    config.kerry_email = 'kerryneeds@gmail.com'

    # design
    config.yuri_email = 'jsenkevich@gmail.com'

    # the reason it has been extracted as app setting is to
    # * keep it DRY & grep-able
    # * hiding cryptic argument names complexity in one place(here). This is needed because this argument is always visibile in GET params, even for regular user.
    config.preview_organization_engagement_as_admin = 'poeaa'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV.fetch('POSTMARK_API_TOKEN') { raise 'missing POSTMARK_API_TOKEN' if Rails.env.staging? || Rails.env.production? } }

    config.time_zone = 'Central Time (US & Canada)'
    config.active_job.queue_adapter = :sidekiq
    config.eager_load_paths << Rails.root.join("lib")

    config.middleware.use ExpiredAuthLinkMiddleware

    config.to_prepare do
      Devise::Mailer.layout "mailer_minimalist"
      Devise::Mailer.helper :mailer
    end
  end
end
