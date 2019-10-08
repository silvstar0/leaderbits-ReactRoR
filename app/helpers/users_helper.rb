# frozen_string_literal: true

module UsersHelper
  # approximate number that fit in 1 line on mobile devices
  MEMBERS_MAX_LENGTH_LINE = 35

  MAGIC_CONSTANT = 6.0

  # shortest text is "4 / 10"(6 chars)
  # longest text is "100 / 100"(9 chars)
  def meter_text_is_visible?(value_text, percent)
    unless (6..9).cover?(value_text.length)
      # new answer type/format?
      raise(%(can not interpret "#{value_text}"))
    end

    min_percent = MAGIC_CONSTANT * value_text.length
    percent >= min_percent
  end

  def extract_responders(combined_results_by_question)
    combined_results_by_question
      .collect { |_question, value| value[:answers] }
      .flatten
      .collect(&:anonymous_survey_participant_id)
      .uniq
      .sort
      .each_with_object({}).with_index do |(anonymous_survey_participant_id, hash), i|
      hash[anonymous_survey_participant_id] = "Person #{i + 1}"
      if current_user.system_admin? || current_user.leaderbits_employee_with_access_to_any_organization?
        asp = AnonymousSurveyParticipant.find(anonymous_survey_participant_id)
        hash[anonymous_survey_participant_id] += %(<br /><small style="cursor: default; color: red" title="NOTE: anonymous_survey_participant_id is only visible to admin">(#{asp.email} - #{asp.role})*</small>)
      end
    end
  end

  def team_member_roles_collection
    [['Member', TeamMember::Roles::MEMBER], ['Leader', TeamMember::Roles::LEADER]]
  end

  def frequency_names
    {
      ProgressReportRecipient::Frequencies::WEEKLY => 'Weekly',
      ProgressReportRecipient::Frequencies::MONTHLY => 'Monthly',
      #"Every 2 weeks" looks rather long
      ProgressReportRecipient::Frequencies::BIMONTHLY => 'Every 2 weeks'
    }
  end

  def progress_report_recipient_frequencies
    #hash = {
    #  ProgressReportRecipient::Frequencies::WEEKLY => 'Weekly',
    #  ProgressReportRecipient::Frequencies::MONTHLY => 'Monthly',
    #  #"Every 2 weeks" looks rather long
    #  ProgressReportRecipient::Frequencies::BIMONTHLY => 'Every 2 weeks'
    #}

    ProgressReportRecipient::Frequencies::ALL.collect { |k| [frequency_names.fetch(k), k] }
  end

  def charge_debug_info(charge)
    #NOTE: invoice could be blank!

    invoice = Stripe::Invoice.retrieve(charge.invoice)
    invoice[:lines].data.first[:description]
  rescue StandardError => e
    logger.error "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"

    #TODO-low prevent charge info from being logged outside? Pass ID instead?
    Rollbar.scoped(charge: charge.inspect, user: current_user.inspect) do
      Rollbar.error(e)
    end
    ''
  end
end
