# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonalizedLeaderbitsQueue do
  example do
    schedule = Schedule.create! name: Schedule::GLOBAL_NAME

    survey_for_leaders = create(:survey, type: Survey::Types::FOR_LEADER)
    anonymous_survey = create(:survey, title: 'Anonymous feedback on how you view your leader', type: Survey::Types::FOR_FOLLOWER)

    leader_user = create(:user, schedule: schedule)

    participant_user1 = create(:anonymous_survey_participant, added_by_user: leader_user, email: 'user1@gmail.com', role: AnonymousSurveyParticipant::Roles::DEFAULT, name: 'user1')
    participant_user2 = create(:anonymous_survey_participant, added_by_user: leader_user, email: 'user2@gmail.com', role: AnonymousSurveyParticipant::Roles::DEFAULT, name: 'user2')
    participant_user3 = create(:anonymous_survey_participant, added_by_user: leader_user, email: 'user3@gmail.com', role: AnonymousSurveyParticipant::Roles::DEFAULT, name: 'user3')
    participant_user4 = create(:anonymous_survey_participant, added_by_user: leader_user, email: 'user4@gmail.com', role: AnonymousSurveyParticipant::Roles::DEFAULT, name: 'user4')

    ### PERSONAL DEVELOPMENT
    question1 = create(:slider_question, survey: survey_for_leaders, count_as_reverse: false)
    create(:question_tag, label: 'Personal Development', question: question1)
    create(:answer_by_leader, user: leader_user, question: question1, params: { "value" => "10" }) # leader rates himself as very good at it

    leaderbit1 = create(:active_leaderbit, name: "One about Personal Development")
    create(:leaderbit_tag, label: 'Personal Development', leaderbit: leaderbit1)


    ### CULTURE
    question = create(:slider_question, survey: survey_for_leaders, count_as_reverse: false)
    create(:question_tag, label: 'Culture', question: question)
    create(:answer_by_leader, user: leader_user, question: question, params: { "value" => "1" }) # leader rates himself as terrible at it

    some_other_question_about_culture = create(:slider_question, survey: survey_for_leaders, count_as_reverse: false)
    create(:question_tag, label: 'Culture', question: some_other_question_about_culture)
    create(:answer_by_leader, user: leader_user, question: some_other_question_about_culture, params: { "value" => "2" }) # leader rates himself on similar question a bit higher but still very low

    leaderbit2 = create(:active_leaderbit, name: "One about Culture")
    create(:leaderbit_tag, label: 'Culture', leaderbit: leaderbit2)


    ### TIME MANAGEMENT
    question = create(:slider_question, survey: survey_for_leaders, count_as_reverse: false)
    create(:question_tag, label: 'Time Management', question: question)
    create(:answer_by_leader, user: leader_user, question: question, params: { "value" => "6" }) # leader rates himself as reasonably good at it

    leaderbit3 = create(:active_leaderbit, name: "One about Time Management")
    create(:leaderbit_tag, label: 'Time Management', leaderbit: leaderbit3)


    ### COMMUNICATION
    question = create(:slider_question, survey: anonymous_survey, count_as_reverse: false)
    create(:question_tag, label: 'Communication', question: question)
    create(:anonymous_answer, anonymous_survey_participant: participant_user1, question: question, params: { "value" => "8" }) # team mates rate leader as reasonably good at it
    create(:anonymous_answer, anonymous_survey_participant: participant_user2, question: question, params: { "value" => "10" })

    leaderbit4 = create(:active_leaderbit, name: "One about Communication")
    create(:leaderbit_tag, label: 'Communication', leaderbit: leaderbit4)


    ### Micro Management
    question = create(:slider_question,
                      survey: anonymous_survey,
                      count_as_reverse: true,
                      params: { "title" => 'What % of the time does %{name} micro-manage the team?', "hint" => nil, "left_side" => 0, "right_side" => 100, "type" => Question::Types::SLIDER })
    create(:question_tag, label: 'Micro Management', question: question)
    # on average leader is rated by team mates as rather bad - 30% of micro management team
    create(:anonymous_answer, anonymous_survey_participant: participant_user3, question: question, params: { "value" => "20" })
    create(:anonymous_answer, anonymous_survey_participant: participant_user4, question: question, params: { "value" => "40" })

    leaderbit5 = create(:active_leaderbit, name: "One about Micro management")
    create(:leaderbit_tag, label: 'Micro Management', leaderbit: leaderbit5)


    ### CREATIVITY
    question = create(:slider_question, survey: anonymous_survey, count_as_reverse: false)
    create(:question_tag, label: 'Creativity', question: question)
    create(:anonymous_answer, anonymous_survey_participant: participant_user1, question: question, params: { "value" => "10" }) # team mates rate leader as really good at it
    create(:anonymous_answer, anonymous_survey_participant: participant_user2, question: question, params: { "value" => "10" })

    leaderbit6 = create(:active_leaderbit, name: "One about Creativity")
    create(:leaderbit_tag, label: 'Creativity', leaderbit: leaderbit6)


    # add in random order
    Leaderbit.active.all.shuffle.each { |l| schedule.leaderbit_schedules.create! leaderbit: l }


    ### LEADERBITS WITHOUT TAGS

    schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit, name: '1st without tag')
    schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit, name: '2nd without tag')
    schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit, name: '3rd without tag')


    result = described_class.new(leader_user).call

    expect(result[0]).to eq(leaderbit1) # leader rated himself as pretty good
    expect(result[1]).to eq(leaderbit5) # anonymous surveyers rated leader very low
    expect(result[2]).to eq(leaderbit6) # anonymous surveyers rated leader as really good
    expect(result[3]).to eq(leaderbit2) # leader rated very low himself
    expect(result[4]).to eq(leaderbit3) # leader rated himself as pretty good
    expect(result[5]).to eq(leaderbit4) # anonymous surveyers rated leader as not bad but still not great

    expect(result[6].name).to eq('1st without tag')
    expect(result[7].name).to eq('2nd without tag')
    expect(result[8].name).to eq('3rd without tag')
    expect(result[9]).to eq(nil)
  end
end
