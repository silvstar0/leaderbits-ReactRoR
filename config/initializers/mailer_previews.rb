# frozen_string_literal: true

# Allow admins to see previews if show_previews enabled.
# It does not affect dev env, as this setting is nil there.
if Rails.application.config.action_mailer.show_previews
  Rails::MailersController.prepend_before_action do
    if !user_signed_in?
      head :forbidden
    elsif Rails.env.production? || Rails.env.test?
      # NOTE: it is intentionally kept the same condition for test & prod environment
      #      motivation is to have functionality visibility test that's not going to lie to you
      head :forbidden unless current_user.system_admin?
    elsif Rails.env.staging?
      # allow everyone signed in on staging to be able to access previews?
      # NOTE: keep in mind that Yuri & Kerry needs to have access to it
    end
  end
end
