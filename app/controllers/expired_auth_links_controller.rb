# frozen_string_literal: true

#TODO rename
class ExpiredAuthLinksController < ActionController::Base
  before_action :set_user, only: %i[show send_link]

  # @see https://stackoverflow.com/a/47183530/74089
  include Rails.application.routes.url_helpers
  class << self
    def default_url_options
      Rails.application.config.action_mailer.default_url_options
    end
  end
  # @see https://stackoverflow.com/a/47183530/74089

  def show
    @original_path = original_path
    #original_path"=>"/leaderbits/24-challenge-being-authentic/start?user_email=amunson%40cradlepoint.com&user_token=G-ANA7GMUMymM45D5Ja7

    respond_to do |format|
      format.html { render layout: 'expired_auth_link' }
    end
  end

  def send_link
    new_token = @user.issue_new_authentication_token_and_return

    uri = URI.parse(params.dig(:user, :original_path))

    #uri.path
    #/leaderbits/24-challenge-being-authentic/start

    root_url_without_trailing_slash = root_url[0..-2]
    url = root_url_without_trailing_slash + uri.path + "?" + { user_token: new_token, user_email: @user.email }.to_query

    Rails.logger.info "user_id=#{@user.id} send_link=#{url.inspect}"

    UserMailer
      .with(
        user: @user,
        url: url
      )
      .your_magic_sign_in_link
      .deliver_later

    #TODO-low why there is this manual created_at setting. Is it still relevant?
    UserSentMagicSignIn.create! user: @user,
                                created_at: 1.second.ago,
                                params: { Rails.configuration.user_sent_email_params_url.to_sym => url }

    respond_to do |format|
      format.html { render layout: 'expired_auth_link' }
    end
  end

  private

  def set_user
    uri = URI.parse original_path

    #uri.path
    #/leaderbits/24-challenge-being-authentic/start

    query_params = CGI.parse uri.query
    #=> {"user_email"=>["amunson@cradlepoint.com"], "user_token"=>["G-ANA7GMUMymM45D5Ja7"]}

    #simple_token_authentication = EmailAuthenticationToken
    @user = EmailAuthenticationToken
              .where(authentication_token: query_params['user_token'],
                     user: User.find_by_email(query_params['user_email']))
              .first!
              .user

    # if simple_token_authentication.present?
    #   @user = simple_token_authentication.user
    #   return
    # end
    #
    # @user = User.where(authentication_token: query_params['user_token'],
    #                    id: User.find_by_email(query_params['user_email']).id).first!
  end

  # it must cover 2 use cases:
  # * redirect from middleware
  # * user submitting "Send Magic Link" form
  # @return [String] e.g. "/leaderbits/24-challenge-being-authentic/start?user_email=amunson%40cradlepoint.com&user_token=G-ANA7GMUMymM45D5Ja7"
  def original_path
    params.dig(:user, :original_path) || params[:original_path]
  end
end
