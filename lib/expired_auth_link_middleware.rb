# frozen_string_literal: true

# The goal of this middleware is *only* in capturing simple_token_authentication auto-login links with expired user_tokens
# and redirecting it to special controller.
# This approach was chosen
#   * to avoid modifying of simple_token_authentication(which is not really friendly for this kind of modification)
#   * to avoid forking of simple_token_authentication
#   * to avoid messing with devise as it may introduce critical bugs
# TODO-High rename middleware because now it does more than it sounds what it is about
class ExpiredAuthLinkMiddleware
  def initialize(app)
    @app = app
  end

  # Try to keep this middleware as simple as possible and add/modify your logic in actual controller where user is redirected.
  def call(env)
    return @app.call(env) unless env["REQUEST_URI"].include?('user_token=')

    request = Rack::Request.new(env)
    # request.path
    # "/leaderbits/2-making-people-feel-heard/start"
    #
    # request.fullpath
    # "/leaderbits/2-making-people-feel-heard/start?user_email=aabraham%40cradlepoint.com&user_token=Qj19AR5FYK55vFwwV-22"

    email_authentication_token = EmailAuthenticationToken
                                   .where(authentication_token: request.params['user_token'])
                                   .first

    #let simple_token_authentication handle it
    return @app.call(env) if email_authentication_token.blank?

    if email_authentication_token.valid_until < Time.now
      return [302, { "Location" => "/expired-auth-link?original_path=#{CGI.escape request.fullpath}" }, []]
    end

    # this is needed because old Magic Links has to stay valid after email update
    latest_user_email = email_authentication_token.user.email
    # think of it as sort of type-casting. In most cases it doesn't change anything but for rare users it is essential
    request.update_param('user_email', latest_user_email)

    # this is needed because token might have likely already re-newed
    latest_user_token = email_authentication_token.user.authentication_token
    request.update_param('user_token', latest_user_token)

    # no special use cases to catch, proceed as normal
    @app.call(env)
  end
end
