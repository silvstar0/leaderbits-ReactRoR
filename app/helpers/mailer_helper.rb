# frozen_string_literal: true

module MailerHelper
  def do_not_forward_email_footer_message
    simple_format <<~HEREDOC
      * Do not forward this email.
      This link is a magic link and will login you into LeaderBits when you click it.
    HEREDOC
  end

  def joel_personal_footer_message
    simple_format <<~HEREDOC
      Talk soon,

      Joel Beasley
      & LeaderBits Team.
    HEREDOC
  end

  #NOTE: result is injected into string like "missed #{missed_weeks_quantity @user} in a row"
  #NOTE: as of Dec 2018 this rake task for each user runs once at 2 weeks at max
  # @return [String] e.g. "2 weeks" or "4 weeks"
  def missed_weeks_quantity(user)
    weeks = user.missed_weeks_quantity

    if weeks.zero? # || (weeks % 2 == 1)
      #it prevents Dont quit mailer from going out so it will be restarted later automatically. Other users are not affected
      raise "Strange missed weeks quantity: #{weeks} for user #{user.email}. Figure it out"
    end

    Rails.logger.info "user_id=#{user.id} missed weeks #{weeks} for #{user.email}"

    pluralize(weeks, 'week')
  end

  # this has to handle 2 use cases:
  # 1) user has ongoing(in-progress) challenge
  # 2) user doesn't have ongoing challenge
  # @return [String]
  def complete_a_challenge_text_in_dont_quit_email(user)
    leaderbit = user.current_leaderbit_in_progress

    if leaderbit.blank?
      leaderbit = user.user_sent_scheduled_new_leaderbits.first&.resource
    end

    if leaderbit.present?
      #NOTE avoid direct links to leaderbit, use start action instead to ensure that it is started first time user sees it
      link_to 'complete a challenge', start_leaderbit_url(leaderbit, user_token: user.issue_new_authentication_token_and_return, user_email: user.email)
    else
      #TODO log/rollbar notify?
      'complete a challenge'
    end
  end

  def leaderbot_footer_message
    #TODO-low make it clickable?
    # think of user case when user doesn't have any clickable links in his email
    raw <<~HEREDOC
      <br>
      Talk soon,
      <br>
      <br>
      #{image_tag 'leaderbot-email.png', alt: 'LeaderBot', width: '293', height: '60'}
    HEREDOC
  end
end
