# frozen_string_literal: true

class OrganizationMonthlyActivityReport
  include ActionView::Helpers::NumberHelper

  def initialize(organizations)
    @organizations = organizations

    fetch_data
  end

  def increment_for_organization(organization)
    user_ids = organization.users.pluck(:id)

    was = @two_months_old_logs.count { |_leaderbit_id, user_id| user_ids.include? user_id }.to_f
    now = @this_month_logs.count { |_leaderbit_id, user_id| user_ids.include? user_id }.to_f
    result = (now - was) / was.to_f * 100.0
    if result.infinite?
      <<-HTML
        <font style="cursor: help" title="Numbers are not comparable because past month's value is zero">N/A</font>
        <div><small style="cursor: help" title="Completed challenges">#{was.to_i} => #{now.to_i}</small></div>
      HTML
    elsif result.positive?
      <<-HTML
        <font style="color: green">+ #{number_to_percentage result, precision: 0}</font>
        <div><small style="cursor: help" title="Completed challenges">#{was.to_i} => #{now.to_i}</small></div>
      HTML
    elsif result.negative?
      <<-HTML
        <font style="color: red">– #{number_to_percentage result.abs, precision: 0}</font>
        <div><small style="cursor: help" title="Completed challenges">#{was.to_i} => #{now.to_i}</small></div>
      HTML
    elsif result.zero?
      <<-HTML
       <font style="">=</font>
        <div><small style="cursor: help" title="Completed challenges">#{was.to_i} => #{now.to_i}</small></div>
      HTML
    else
      <<-HTML
       <font style="">=</font>
        <div><small style="cursor: help" title="Completed challenges">#{was.to_i} => #{now.to_i}</small></div>
      HTML
    end
  end

  private

  def fetch_data
    range1 = 2.months.ago..1.month.ago
    range2 = 1.month.ago..Time.now

    @two_months_old_logs = LeaderbitLog
                             .completed
                             .where(updated_at: range1)
                             .pluck(:leaderbit_id, :user_id)

    @this_month_logs = LeaderbitLog
                         .completed
                         .where(updated_at: range2)
                         .pluck(:leaderbit_id, :user_id)
  end
end
