# frozen_string_literal: true

module ApplicationHelper
  #TODO move to adminhelper
  def active_users(organization, highly_active_users)
    since_at = activity_date_range(organization).first
    until_at = activity_date_range(organization).last

    organization
      .users
      .active_recipient
      .where.not(id: highly_active_users.collect(&:id))
      .where('users.created_at < ?', until_at)
      .where('users.id IN(SELECT user_id FROM leaderbit_logs WHERE status = ? AND updated_at >= ? AND updated_at < ?)', LeaderbitLog::Statuses::COMPLETED, since_at, until_at)
  end

  def add_javascript_content_for_current_momentum(options)
    user = options.fetch(:user)
    donut_width = options.fetch(:donut_width) { 5 }
    custom_height = options.fetch(:height) { nil }

    content_for :javascript do
      raw <<~JS
        (function() {
          new Chartist.Pie('.chartist-current-momentum-container', {
            series: [#{user.momentum}, #{100 - user.momentum}]
          }, {
                             donut: true,
                             donutWidth: #{donut_width},
                             donutSolid: false,
                             startAngle: 0,
                             total: 100.01,
                             #{custom_height ? "height: '#{custom_height}'," : ''}
                             showLabel: false
                           });
        })();
      JS
    end
  end

  def add_javascript_content_for_raw_metric(options)
    placeholder_selector = options.fetch(:placeholder_selector)
    donut_width = options.fetch(:donut_width) { 5 }
    custom_height = options.fetch(:height) { nil }

    value = options.fetch(:value)

    total = value.positive? ? value : 100

    content_for :javascript do
      raw <<~JS
        (function() {
          new Chartist.Pie('#{placeholder_selector}', {
            series: [#{value}, #{total}]
          }, {
                             donut: true,
                             donutWidth: #{donut_width},
                             donutSolid: false,
                             startAngle: 0,
                             total: #{total},
                             #{custom_height ? "height: '#{custom_height}'," : ''}
                             showLabel: false
                           });
        })();
      JS
    end
  end

  def add_javascript_content_for_line_chart(options)
    placeholder_selector = options.fetch(:placeholder_selector)
    data = options.fetch(:data)
    #height = options.fetch(:height) { 'auto' }
    height = options.fetch(:height) { nil }

    content_for :javascript do
      raw <<~JS
        (function () {
          var rawData = #{raw data.to_json};
          var seriesData = [];
          for (var key in rawData) {
            if (rawData.hasOwnProperty(key)) {
              seriesData.push({x: new Date(Number(key) * 1000), y: rawData[key]});
            }
          }
          new Chartist.Line('#{placeholder_selector}', {
            series: [
              {
                data: seriesData
              }
            ]
          }, {
            #{height ? "height: '#{height}'," : ''}
            low: 0,
            showArea: true,
            axisX: {
              type: Chartist.FixedScaleAxis,
              divisor: 5,
              labelInterpolationFnc: function(value) {
                return moment(value).format('MMM D Y');
              }
            }
          });
        })();
      JS
    end
  end

  #TODO move to adminhelper
  def highly_active_users(organization)
    since_at = activity_date_range(organization).first
    until_at = activity_date_range(organization).last

    organization.users.active_recipient.where('users.created_at < ?', until_at).select do |user|
      completed = LeaderbitLog.completed.where(user: user).where('updated_at >= ? AND updated_at < ?', since_at, until_at).count

      received_leaderbit_ids_during_time_range = user.received_uniq_leaderbit_ids_at_time(until_at) - user.received_uniq_leaderbit_ids_at_time(since_at)
      leader_is_highly_active?(completed, received_leaderbit_ids_during_time_range.count)
    end
  end

  def can_add_new_mentee?
    (current_user.can_create_a_mentee? && choose_mentee_collection.present?) || (current_user.can_create_a_mentee? && !OrganizationalMentorship.where(mentor_user_id: current_user.id).exists?)
  end

  def question_title(question)
    if @anonymous_survey_participant.present?
      question
        .title
        .gsub('%{name}', @anonymous_survey_participant.added_by_user.first_name)
        .gsub('%{name_possessive}', @anonymous_survey_participant.added_by_user.first_name.possessive)
    else
      # strenght finder survey
      question.title
    end
  end

  #TODO this tricky method needs explanation. Extract slack log from early morning May 09(with Fabiana)
  def direct_report_question(question_anonymous_survey_similarity_uuid)
    Question
      .where(anonymous_survey_similarity_uuid: question_anonymous_survey_similarity_uuid)
      .where('surveys.type = ?', Survey::Types::FOR_FOLLOWER)
      .where('surveys.anonymous_survey_participant_role = ?', AnonymousSurveyParticipant::Roles::DIRECT_REPORT)
      .joins(:survey)
      .first!
  end

  #NOTE: this helper method is used for Admins AND Emails timeline(for users)
  def user_sent_email_to_s(user_sent_email)
    user_sent_email.human_description current_user: current_user
  rescue StandardError => e
    Rails.logger.error "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(10).join(' | ')}"
    raise(e) if Rails.env.development? || Rails.env.test?

    Rollbar.scoped(current_user: current_user.inspect, user_sent_email: user_sent_email.inspect) do
      Rollbar.info(e)
    end
    ''
  end

  #The goal of this method is to make devise sessions/new form look non confusing when user is redirected there
  # after he requested his password to be reset from "Your Profile" link
  def display_regular_devise_wording_and_links?
    # could be like this when you reset password from Your Profile
    # http://localhost:4000/organizations/1-grady-schimmel/users/c9e8b01/edit
    if request.referer.present? && request.referer.include?('/users') && request.referer.include?('/edit')
      return false
    end

    true
  end

  def leadership_strength_finder_form_url
    return '/noway' if params[:user_id].present? # preview mode for admin/employee

    survey_answers_path(@survey)
  end

  def display_strength_levels_preview_link?(user_id:)
    #daily cache key is good enough for now for this feature
    Rails.cache.fetch("#{__method__}//#{Date.today.to_s(:db)}") do
      UserStrengthLevel.pluck(:user_id).uniq
    end.include?(user_id)
  end

  #NOTE add your custom adjustments to class name constructions here if you need to
  # e.g. Zurb has its own handling of ".progress" classes
  def extended_body_class(options = {})
    body_class(options)
  end

  #TODO-low abstract common code with #tracking_leaderbit_video_iframe
  def tracking_welcome_video_iframe(args)
    content_for(:javascript) do
      raw <<~HTML
        function postMsg(id) {
          if (id == null || id == '') {
            // because privacy settings are different on staging
            return;
          }
          var msg = {
            method: "addEventListener",
            value: 'playProgress'
          };
          var iframe = document.getElementById(id), cW;
          if(iframe) cW = iframe.contentWindow;
          if(!cW){setTimeout(function(){postMsg(id)}, 200); return;}
          cW.postMessage(JSON.stringify(msg), '*');
        }

        var messageListener = function(messageEvent) {
          if (!(/^https?:\\/\\/player.vimeo.com/).test(messageEvent.origin)) {
            return false;
          }

          if (typeof(messageEvent.data) == 'string') {
            var messageEventData = JSON.parse(messageEvent.data);
          } else {
            // on staging, privacy settings are different. e.data is json, no need to parse then
            var messageEventData = messageEvent.data;
          }

          if (messageEventData.event === 'ready') { postMsg(messageEventData.player_id) };
          if (messageEventData.event === 'playProgress') { onPlayProgress(messageEventData) };
        }

        var lastSecondReported = 0;
        function onPlayProgress(messageEventData) {
          if (messageEventData.data.seconds > lastSecondReported) {
            App.video.track({
              seconds: messageEventData.data.seconds,
              percent: messageEventData.data.percent,
              duration: messageEventData.data.duration,
            });
            lastSecondReported++;
          }
          var completedPercent = messageEventData.data.seconds / messageEventData.data.duration;
          if (completedPercent > 0.96) {
            document.getElementById('#{args.fetch(:on_finish_display_element_id)}').classList.remove('invisible');
            document.getElementById('#{args.fetch(:on_finish_hide_element_id)}').classList.add('invisible');

            //NOTE: it may send AJAX request a few times
            fetch('/onboarding', {
              method: 'post',
              credentials: 'include',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                last_seen_url: document.location.href
              })
            });

          }
        }
        var iframe = document.querySelector('iframe');
        window.addEventListener('message', messageListener, false);
      HTML
    end

    raw %(<iframe id="welcomeVideo" src="#{Rails.configuration.welcome_video_url}?player_id=welcomeVideo" frameborder="0" allowfullscreen="allowfullscreen"></iframe>)
  end

  #TODO-low abstract common code with #tracking_welcome_video_iframe
  def tracking_leaderbit_video_iframe(leaderbit)
    content_for(:javascript) do
      raw <<~HTML
        function postMsg(id) {
          if (id == null || id == '') {
            // because privacy settings are different on staging
            return;
          }

          var msg = {
              method: "addEventListener",
              value: 'playProgress'
          };

          var iframe = document.getElementById(id), cW;
          if (iframe) {
            cW = iframe.contentWindow;
          }
          if (!cW) { setTimeout(function() { postMsg(id) }, 200); return; }
          cW.postMessage(JSON.stringify(msg), '*');
        }

        var messageListener = function(messageEvent){
          if (!(/^https?:\\/\\/player.vimeo.com/).test(messageEvent.origin)) {
            return false;
          }

          if (typeof(messageEvent.data) == 'string') {
            var messageEventData = JSON.parse(messageEvent.data);
          } else {
            // on staging, privacy settings are different. e.data is json, no need to parse then
            var messageEventData = messageEvent.data;
          }

          if (messageEventData.event === 'ready') { postMsg(messageEventData.player_id) };
          if (messageEventData.event === 'playProgress') { onPlayProgress(messageEventData) };
        }

        var lastSecondReported = 0;
        function onPlayProgress(messageEventData) {
          if (messageEventData.data.seconds > lastSecondReported) {
            App.video.track({
              seconds: messageEventData.data.seconds,
              percent: messageEventData.data.percent,
              duration: messageEventData.data.duration,
              leaderbit_id: #{@leaderbit.id},
              video_session_id: "#{@video_session_id}"
            });
            lastSecondReported++;
          }
        }
        var iframe = document.querySelector('iframe');
        window.addEventListener('message', messageListener, false);
      HTML
    end

    raw %(<iframe id="#{leaderbit.video_frame_id}" src="#{leaderbit.url_with_frame_id}" width="100%" height="350" frameborder="0" allowfullscreen="allowfullscreen"></iframe>)
  end

  def pluralize_without_count(count, noun, text = nil)
    raise ArgumentError if count.zero?

    count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
  end

  # NOTE : do not return in wrapped in some A tag link. It is used in new_leaderbit template where link is #start instead
  # NOTE: in case you update this method, test it in new_leaderbit mailer preview at least
  # NOTE: re-test everywhere it is used in case you want to remove "width: 100%"
  def video_cover(leaderbit)
    #because ActionController::RoutingError: No route matches [GET] "/images/video_covers/default.png" in specs
    if Rails.env.test?
      width = 450
      return image_tag("https://via.placeholder.com/#{width}x#{(width / 1.61).to_i}/E8117F/000000?text=#{CGI.escape leaderbit.persisted? ? leaderbit.clean_name : 'LeaderBit'}", style: 'width: 100%')
    end

    Rails.cache.fetch "#{__method__}/ver2/#{leaderbit.cache_key_with_version}" do
      if leaderbit.video_cover.attached?
        begin
          image_tag leaderbit.video_cover.variant(resize: '1350x1350').processed.service_url(expires_in: false), title: leaderbit.name, style: 'width: 100%'
        rescue StandardError => e
          Rollbar.error(e)
          image_tag 'video_covers/default.png', title: leaderbit.name, style: 'width: 100%'
        end
      else
        image_tag 'video_covers/default.png', title: leaderbit.name, style: 'width: 100%'
      end
    end
  end

  def logo(organization)
    #because ActionController::RoutingError: No route matches [GET] "/images/video_covers/default.png" in specs
    return image_tag("https://via.placeholder.com/450x255/E8117F/000000?text=#{CGI.escape organization.persisted? ? organization.name : 'logo'}", width: 450) if Rails.env.test?

    Rails.cache.fetch "#{__method__}/#{organization.cache_key_with_version}" do
      if organization.logo.attached?
        begin
          image_tag organization.logo.variant(resize: '1350x1350').processed.service_url(expires_in: false), style: 'height: 100px', title: organization.name
        rescue StandardError => e
          Rollbar.error(e)
          image_tag 'leaderbits_logo_horizontal_gray.png', style: 'height: 100px', title: organization.name
        end
      else
        image_tag 'leaderbits_logo_horizontal_gray.png', style: 'height: 100px', title: organization.name
      end
    end
  end

  def display_points_indicator?
    return true if action_name == 'dashboard'
    return true if controller_name == 'leaderbits' && (action_name == 'show' || action_name == 'index')

    false
  end

  # @return [Integer]
  def data_initial_start(question)
    return question.left_side if params[:user_id].blank?
    return question.left_side unless Answer.where(user: @user).exists?

    Answer.where(user: @user, question: question).first!.params['value']
  end
end
