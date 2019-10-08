# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Mailer Previews & blazer queries", type: :feature, js: true do
  let(:organization) { create(:organization, active_since: 6.weeks.ago, first_leaderbit_introduction_message: "Hi Team,\r\n\r\n    I’m writing to let you know #{Faker::Hacker.say_something_smart}") }
  let!(:organization2) { create(:organization, active_since: 3.weeks.ago, first_leaderbit_introduction_message: nil) }
  let!(:user) { create(:user, created_at: 2.weeks.ago, organization: organization) }
  let!(:joel) { create(:user, created_at: 2.weeks.ago, email: Rails.configuration.joel_email, organization: organization) }
  let!(:old_user) { create(:user, created_at: 40.days.ago, organization: organization) }
  let!(:leaderbit) { create(:leaderbit) }
  let!(:leaderbit2) { create(:leaderbit) }
  let!(:leaderbit_log) { create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit) }

  let!(:completed_leaderbit_log) { create(:leaderbit_log, user: User.all.sample, leaderbit: leaderbit2, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 3.weeks.ago) }
  let!(:entry_group_on_completed_leaderbit_log) { create(:entry_group, leaderbit: leaderbit2, user: completed_leaderbit_log.user) }
  let!(:entry_on_completed_leaderbit_log) { create(:entry, content: 'my content', leaderbit: leaderbit2, user: completed_leaderbit_log.user, entry_group: entry_group_on_completed_leaderbit_log, created_at: 2.weeks.ago) }

  let!(:team) { create(:team, organization: organization) }
  let!(:user2) { create(:user, created_at: 3.weeks.ago, c_level: true, organization: organization) }

  let!(:user_team_leader) do
    create(:user, created_at: 3.weeks.ago, organization: organization).tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::LEADER }
  end

  let!(:user_team_member) do
    create(:user, created_at: 3.weeks.ago, organization: organization).tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::MEMBER }
  end

  let!(:entry_reply) { create(:entry_reply, parent_reply_id: nil) }
  let!(:reply_on_reply) do
    create(:entry_reply,
           user: User.all.sample,
           parent_reply_id: EntryReply.where(parent_reply_id: nil).first!.id,
           content: Faker::Hacker.say_something_smart + ' ' + Faker::Internet.url(host: 'app.leaderbits.com'))
  end

  let!(:liked_reply) do
    create(:entry_reply, entry: Entry.all.sample).tap { |reply| reply.entry.liked_by User.all.sample }
  end
  let!(:entry_for_boomerang) { create(:entry, discarded_at: nil) }
  let!(:double_entry_for_boomerang) do
    entry = Entry.first
    create(:entry, entry_group: entry.entry_group, leaderbit: entry.leaderbit, user: entry.user)
  end

  let!(:leaderbit_log2) { create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit) }
  let!(:user_sent_scheduled_new_leaderbit) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit_log2.leaderbit, user: leaderbit_log2.user) }
  let!(:user_sent_scheduled_new_leaderbit2) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit) }

  let!(:survey1) { create(:survey, type: Survey::Types::FOR_LEADER) }

  let!(:survey2) { create(:survey, type: Survey::Types::FOR_FOLLOWER, anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT, title: 'Anonymous feedback on how you view %{name} as a leader') }
  let!(:question1) { create(:slider_question, anonymous_survey_similarity_uuid: 'abc', survey: survey2) }
  let!(:question2) { create(:slider_question, anonymous_survey_similarity_uuid: 'def', survey: survey2) }

  let!(:survey3) { create(:survey, type: Survey::Types::FOR_FOLLOWER, anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::LEADER_OR_MENTOR, title: 'Anonymous feedback on how you view %{name} as a leader') }
  let!(:survey4) { create(:survey, type: Survey::Types::FOR_FOLLOWER, anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::PEER, title: 'Anonymous feedback on how you view %{name} as a leader') }
  let!(:anonymous_survey_participant1) { create(:anonymous_survey_participant, role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT, added_by_user: User.all.sample) }
  let!(:anonymous_survey_participant2) { create(:anonymous_survey_participant, role: AnonymousSurveyParticipant::Roles::LEADER_OR_MENTOR, added_by_user: User.all.sample) }
  let!(:anonymous_survey_participant3) { create(:anonymous_survey_participant, role: AnonymousSurveyParticipant::Roles::PEER, added_by_user: User.all.sample) }

  let!(:answer1) { create(:anonymous_answer, user: nil, anonymous_survey_participant: anonymous_survey_participant1, question: question1) }
  let!(:answer2) { create(:anonymous_answer, user: nil, anonymous_survey_participant: anonymous_survey_participant1, question: question2) }

  let!(:mentorship) { create(:organizational_mentorship, mentor_user: User.all.sample, mentee_user: User.all.sample) }
  let!(:progress_report_recipient) { create(:progress_report_recipient, added_by_user_id: User.all.sample.id) }

  #NOTE the reason why 2 different test suites are combined here is to make it faster.
  # they change rarely but executed every time
  it 'does not fail' do
    user = create(:system_admin_user, created_at: 3.weeks.ago)
    login_as(user, scope: :user, run_callbacks: false)

    # it does not fail for all preview mailer templates
    ActionMailer::Preview.all.each do |preview|
      puts "#{preview.preview_name.titleize}: " if ENV['DEBUG']
      preview.emails.each do |email|
        path = "/rails/mailers/#{preview.preview_name}/#{email}"

        puts " => #{path}" if ENV['DEBUG']
        visit path
        expect(page).to have_content('From')
        expect(page).to have_content('To')
        expect(page).to have_content('Date')
        expect(page).to have_content('Subject')
      end
    end

    ActiveRecord::Base.connection.execute(BlazerMigration.new(queries_on_behalf_of_user: User.first!).to_sql).values
    max_id = ActiveRecord::Base.connection.execute('SELECT MAX(id) FROM blazer_queries').values.flatten.compact.first
    #IDX
    idx = 3
    #IDY
    idy = 4
    #IDZ
    idz = 16

    #NOTE: if you want to automate it you may check blazer queries for presence of "{email}" and filter generic vs per user(filtered) queries like that
    (1..max_id).to_a.without(idx, idy, idz).each do |i|
      path = "/blazer/queries/#{i}"
      puts " => #{path}" # if ENV['DEBUG']
      visit path
      expect(page).to have_content('Home')
      expect(page).to have_content('row')
    end

    #LeaderBits watch time by user
    path = "/blazer/queries/#{idx}?email=#{User.all.sample.email}"
    puts " => #{path}" # if ENV['DEBUG']
    visit path
    expect(page).to have_content('Home')
    expect(page).to have_content('row')

    #Momentum by user
    path = "/blazer/queries/#{idy}?email=#{User.all.sample.email}"
    puts " => #{path}" # if ENV['DEBUG']
    visit path
    expect(page).to have_content('Home')
    expect(page).to have_content('row')

    # Answers to *List 3 ways %{name} could improve.* for specific user
    path = "/blazer/queries/#{idz}?email=#{User.all.sample.email}"
    puts " => #{path}" # if ENV['DEBUG']
    visit path
    expect(page).to have_content('Home')
    expect(page).to have_content('Home')
    expect(page).to have_content('row')
  end

  def does_not_have_mailer_preview_capability
    expect(page).not_to have_content('Mailer')
    expect(page).not_to have_title('Mailer Previews')

    # expect(page.status_code).to eq('404')
  end

  context 'given not-signed in/guest user' do
    it 'does not have mailer preview capability' do
      visit '/rails/mailers'

      # expect(page).to have_content('You need to sign in')
      # expect(page).to have_content('Forgot your password')
      # expect(page.body).to include('<input')
      #
      # sleep 1
      does_not_have_mailer_preview_capability
    end
  end

  context 'given signed in regular team member user(without sys admin role)' do
    before do
      user = create(:user)
      login_as(user, scope: :user, run_callbacks: false)
    end

    it 'does not have mailer preview capability', type: :feature do
      visit '/rails/mailers'
      # expect(page).to have_content('Logout')

      # sleep 1
      does_not_have_mailer_preview_capability
    end
  end
end
