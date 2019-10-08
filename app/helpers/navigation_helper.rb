# frozen_string_literal: true

module NavigationHelper
  def preview_path_for_user_sent_email(user_sent_email)
    format = '%-m/%-d/%y'
    low_date = user_sent_email.created_at.beginning_of_day.to_date

    query_params = {
      'utf8' => '✓',
      'f' => {
        'low_date' => low_date.strftime(format),
        'high_date' => low_date.next.strftime(format),
        'range' => 'custom',
        'query' => user_sent_email.user.email,
        'event_types' => ['MTAEvent', 'OpenedEvent']
      }
    }

    "https://account.postmarkapp.com/servers/3825011/delivery_events/outbound?#{query_params.to_query}"
  end
end
