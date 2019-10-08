# frozen_string_literal: true

class PersonalizedLeaderbitsQueue
  def initialize(leader_user)
    @leader_user = leader_user
  end

  #TODO think about preemptive queue as well
  def call
    enumerator = if anonymous_answers_by_tag_label.present? && leader_answers_by_tag_label.present?
                   [
                     topics_i_ve_confessed_im_good_at_as_leader,
                     topics_people_telling_me_im_not_good_at,
                     topics_people_telling_me_im_good_at,
                     topics_i_ve_confessed_im_not_good_at_as_leader
                   ].cycle
                 elsif anonymous_answers_by_tag_label.present?
                   [
                     topics_people_telling_me_im_good_at,
                     topics_people_telling_me_im_not_good_at
                   ].cycle
                 elsif leader_answers_by_tag_label.present?
                   [
                     topics_i_ve_confessed_im_good_at_as_leader,
                     topics_i_ve_confessed_im_not_good_at_as_leader
                   ].cycle
                 else
                   # just return nil and it all will be replaced with regular schedule leaderbits
                   [->(_opts) { nil }].cycle
                 end

    result = []
    leaderbits_with_tags_to_choose_from = leaderbits_with_tags
    number_of_leaderbits_in_leaders_plan.times do
      leaderbit = enumerator.next.call leaderbits_with_tags_to_choose_from: leaderbits_with_tags_to_choose_from
      puts if ENV['DEBUG']

      result << leaderbit
      leaderbits_with_tags_to_choose_from.transform_values! { |array_of_leaderbits| array_of_leaderbits.without(leaderbit) }
    end

    left_leaderbits_to_choose_from = regular_list - result
    result.collect do |leaderbit|
      next leaderbit if leaderbit.present?

      replacement_leaderbit_from_main_schedule = left_leaderbits_to_choose_from.shift
      puts "Just replaced blank leaderbit with #{replacement_leaderbit_from_main_schedule.name}" if ENV['DEBUG']
      replacement_leaderbit_from_main_schedule
    end
  end

  private

  def anonymous_answers_by_tag_label
    return @anonymous_answers_by_tag_label if defined?(@anonymous_answers_by_tag_label)

    # @anonymous_answers_by_tag_label = @leader_user
    #                                     .anonymous_survey_participants
    #                                     .pluck(:email)
    #                                     .yield_self { |emails| Answer.where(by_user_with_email: emails) }
    #                                     .yield_self(&method(:answers_to_question_tags_on_average))
    #                                     .tap { |r| puts(r) if ENV['DEBUG'] }
    @anonymous_answers_by_tag_label = Answer
                                        .where(user: nil)
                                        .where('anonymous_survey_participant_id IN (SELECT id FROM anonymous_survey_participants WHERE added_by_user_id = ?)', @leader_user.id)
                                        .yield_self(&method(:answers_to_question_tags_on_average))
                                        .tap { |r| puts(r) if ENV['DEBUG'] }
  end

  def leader_answers_by_tag_label
    return @leader_answers_by_tag_label if defined?(@leader_answers_by_tag_label)

    @leader_answers_by_tag_label = @leader_user
                                     .answers
                                     .yield_self(&method(:answers_to_question_tags_on_average))
                                     .tap { |r| puts(r) if ENV['DEBUG'] }
  end

  def number_of_leaderbits_in_leaders_plan
    regular_list.count
  end

  def topics_i_ve_confessed_im_not_good_at_as_leader
    ->(opts) do
      puts "Checking topics where I've said I'm not good at" if ENV['DEBUG']
      leaderbits_with_tags_to_choose_from = opts.fetch(:leaderbits_with_tags_to_choose_from)

      leader_answers_by_tag_label
        .sort(&ascending_sort) #=> [["Personal Development", 10.0], ["Culture", 1.5]]
        .each do |label, _average_value|
        leaderbit = leaderbits_with_tags_to_choose_from[label]&.first
        next unless leaderbit.present?

        puts "Got one: #{leaderbit.name}" if ENV['DEBUG']
        return leaderbit
      end
      puts "Couldn't find one" if ENV['DEBUG']
      nil
    end
  end

  def topics_i_ve_confessed_im_good_at_as_leader
    ->(opts) do
      puts "Checking topics where I've said I'm good at" if ENV['DEBUG']
      leaderbits_with_tags_to_choose_from = opts.fetch(:leaderbits_with_tags_to_choose_from)

      leader_answers_by_tag_label
        .sort(&descending_sort) #=> [["Culture", 1.5], ["Personal Development", 10.0]]
        .each do |label, _average_value|
        leaderbit = leaderbits_with_tags_to_choose_from[label]&.first
        next unless leaderbit.present?

        puts "Got one: #{leaderbit.name}" if ENV['DEBUG']
        return leaderbit
      end
      puts "Couldn't find one" if ENV['DEBUG']
      nil
    end
  end

  def topics_people_telling_me_im_not_good_at
    ->(opts) do
      puts "Checking topics people telling me I'm NOT good at" if ENV['DEBUG']
      leaderbits_with_tags = opts.fetch(:leaderbits_with_tags_to_choose_from)

      anonymous_answers_by_tag_label
        .sort(&ascending_sort) #=> [["Communication", 1.5]]
        .each do |label, _average_value|
        leaderbit = leaderbits_with_tags[label]&.first
        next unless leaderbit.present?

        puts "Got one: #{leaderbit.name}" if ENV['DEBUG']
        return leaderbit
      end

      puts "Couldn't find one" if ENV['DEBUG']
      nil
    end
  end

  def topics_people_telling_me_im_good_at
    ->(opts) do
      puts "Checking topics people telling me I'm good at" if ENV['DEBUG']
      leaderbits_with_tags = opts.fetch(:leaderbits_with_tags_to_choose_from)

      anonymous_answers_by_tag_label
        .sort(&descending_sort) #=> [["Communication", 1.5]]
        .each do |label, _average_value|
        leaderbit = leaderbits_with_tags[label]&.first
        next unless leaderbit.present?

        puts "Got one: #{leaderbit.name}" if ENV['DEBUG']
        return leaderbit
      end

      puts "Couldn't find one" if ENV['DEBUG']
      nil
    end
  end

  # @return [Leaderbit]
  def regular_list
    return @regular_list if defined?(@regular_list)

    @regular_list = @leader_user
                      .schedule
                      .leaderbit_schedules
                      .includes(:leaderbit)
                      .where('leaderbits.active' => true)
                      .order(position: :asc)
                      .collect(&:leaderbit)
  end

  #=> @return [Hash] - e.g. {"Communication"=> [Leaderbit]}
  def leaderbits_with_tags
    return @leaderbits_with_tags if defined?(@leaderbits_with_tags)

    @leaderbits_with_tags = regular_list.each_with_object({}) do |leaderbit, hash|
      leaderbit.tags.collect(&:label).each do |label|
        hash[label] ? hash[label] << leaderbit : hash[label] = [leaderbit]
      end
    end
  end

  # example - a.inspect
  # => ["Culture", 1.5]
  def ascending_sort
    ->(a, b) { a.last <=> b.last }
  end

  # example - a.inspect
  # => ["Culture", 1.5]
  def descending_sort
    ->(a, b) { b.last <=> a.last }
  end

  #@return [Hash] e.g. {"Personal Development"=>10.0, "Culture"=>1.5}
  def answers_to_question_tags_on_average(relation)
    relation
      .each_with_object({}) do |a, hash|
        a.question.tags.collect(&:label).each do |label_title|
          val_aware_of_reverse_flag = if a.question.count_as_reverse?
                                        a.question.params['right_side'].to_i - a.params['value'].to_i
                                      else
                                        a.params['value'].to_i
                                      end
          #val.inspect
          #=> 8

          # max is 1
          val_aware_of_max_scale_and_reverse_flag = val_aware_of_reverse_flag.to_f / a.question.params['right_side'].to_i
          #val_aware_of_max_scale.inspect
          #0,01

          hash[label_title] ? hash[label_title] << val_aware_of_max_scale_and_reverse_flag : hash[label_title] = [val_aware_of_max_scale_and_reverse_flag]
        end
      end.transform_values { |v| v.reduce(:+) / v.size.to_f }
  end
end
