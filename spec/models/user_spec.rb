# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                                                                                                                                                          :bigint(8)        not null, primary key
#  email                                                                                                                                                                       :string           default(""), not null
#  encrypted_password                                                                                                                                                          :string           default(""), not null
#  reset_password_token                                                                                                                                                        :string
#  reset_password_sent_at                                                                                                                                                      :datetime
#  remember_created_at                                                                                                                                                         :datetime
#  sign_in_count                                                                                                                                                               :integer          default(0), not null
#  current_sign_in_at                                                                                                                                                          :datetime
#  last_sign_in_at                                                                                                                                                             :datetime
#  current_sign_in_ip                                                                                                                                                          :inet
#  last_sign_in_ip                                                                                                                                                             :inet
#  created_at                                                                                                                                                                  :datetime         not null
#  updated_at                                                                                                                                                                  :datetime         not null
#  organization_id                                                                                                                                                             :bigint(8)        not null
#  time_zone                                                                                                                                                                   :string
#  authentication_token                                                                                                                                                        :string(30)
#  hour_of_day_to_send                                                                                                                                                         :integer          not null
#  day_of_week_to_send                                                                                                                                                         :string           not null
#  uuid                                                                                                                                                                        :string           not null
#  intercom_user_id                                                                                                                                                            :string
#  discarded_at                                                                                                                                                                :datetime
#  schedule_id                                                                                                                                                                 :integer
#  leaderbits_sending_enabled                                                                                                                                                  :boolean          default(TRUE), not null
#  welcome_video_seen_seconds                                                                                                                                                  :integer
#  notify_me_if_i_missing_2_weeks_in_a_row(accountability feature)                                                                                                             :boolean          default(TRUE)
#  notify_observer_if_im_trying_to_hide(accountability feature)                                                                                                                :boolean          default(FALSE)
#  notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks(accountability feature)                                                                                     :bigint(8)
#  admin_notes                                                                                                                                                                 :text
#  admin_notes_updated_at                                                                                                                                                      :datetime
#  last_seen_audit_created_at(needed for properly counting unseen new audit logs in Admin interface)                                                                           :datetime
#  goes_through_leader_welcome_video_onboarding_step(1st step by default for a new leader)                                                                                     :boolean          not null
#  goes_through_organizational_mentorship_onboarding_step(4th step by default for a new leader)                                                                                :boolean          not null
#  c_level(gives additional abilities within his organization)                                                                                                                 :boolean          default(FALSE), not null
#  system_admin(highest role in the system - Joel, Fabiana etc)                                                                                                                :boolean          default(FALSE), not null
#  personalized_leaderbits_algorithm_instead_of_regular_schedule                                                                                                               :boolean
#  goes_through_leader_strength_finder_onboarding_step(2nd step by default for a new leader)                                                                                   :boolean          not null
#  goes_through_team_survey_360_onboarding_step(3rd step by default for a new leader)                                                                                          :boolean          not null
#  created_by_user_id(needed so that we can distinguish users created by admin/employee from those created by organizational mentors)                                          :integer
#  can_create_a_mentee                                                                                                                                                         :boolean          default(FALSE), not null
#  name                                                                                                                                                                        :string
#  last_completed_onboarding_step_for_active_recipient(applies only to active recipients, for others there is #first_entry_for_non_active_leaderbits_recipient_user_to_review) :string
#
# Foreign Keys
#
#  fk_rails_...  (notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks => progress_report_recipients.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (schedule_id => schedules.id)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#initials_color' do
    example do
      user = create(:user)
      mentor1 = create(:user)
      mentor2 = create(:user)
      mentor3 = create(:user)
      mentor4 = create(:user)
      mentor5 = create(:user)
      mentor6 = create(:user)

      LeaderbitEmployeeMentorship.create! mentor_user: mentor1, mentee_user: user
      LeaderbitEmployeeMentorship.create! mentor_user: mentor2, mentee_user: user
      LeaderbitEmployeeMentorship.create! mentor_user: mentor3, mentee_user: user
      LeaderbitEmployeeMentorship.create! mentor_user: mentor4, mentee_user: user
      LeaderbitEmployeeMentorship.create! mentor_user: mentor5, mentee_user: user
      LeaderbitEmployeeMentorship.create! mentor_user: mentor6, mentee_user: user

      expect(mentor1.initials_color.to_s).to eq('#4a90e2')
      expect(mentor2.initials_color.to_s).to eq('#e24adc')
      expect(mentor3.initials_color.to_s).to eq('#e29c4a')
      expect(mentor4.initials_color.to_s).to eq('#4ae250')

      expect(mentor5.initials_color.to_s).to eq('#4a90e2')
      expect(mentor6.initials_color.to_s).to eq('#e24adc')
    end
  end

  describe '#name_initials' do
    example do
      user = described_class.new(name: 'Fabiana Leal Pereira')
      expect(user.name_initials).to eq('FLP')

      user = described_class.new(name: 'John Brown')
      expect(user.name_initials).to eq('JB')
    end
  end

  describe '#update_last_completed_onboarding_step' do
    let(:user) {
      create(:user,
             goes_through_leader_welcome_video_onboarding_step: true,
             goes_through_leader_strength_finder_onboarding_step: true,
             goes_through_team_survey_360_onboarding_step: true,
             goes_through_organizational_mentorship_onboarding_step: true)
    }

    context 'given completely new user' do
      example do
        expect {
          user.update_last_completed_onboarding_step User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP
        }.to change { user.reload.last_completed_onboarding_step_for_active_recipient }.from(nil).to(User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP)
      end
    end

    context 'given user going to the very next step' do
      example do
        user.update_column :last_completed_onboarding_step_for_active_recipient, User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP

        expect {
          user.update_last_completed_onboarding_step User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP
        }.to change { user.reload.last_completed_onboarding_step_for_active_recipient }.from(User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP).to(User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP)
      end
    end

    context 'given user manually opening previous step' do
      example do
        user.update_column :last_completed_onboarding_step_for_active_recipient, User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP

        expect {
          user.update_last_completed_onboarding_step User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP
        }.not_to change { user.reload.last_completed_onboarding_step_for_active_recipient }.from(User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP)
      end
    end
  end

  describe '#average_anonymous_completed_answers_results' do
    let!(:survey) { create(:survey, title: 'Anonymous feedback on how you view your leader', anonymous_survey_participant_role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT, type: Survey::Types::FOR_FOLLOWER) }

    let!(:question1) { create(:slider_question, anonymous_survey_similarity_uuid: 'abc', survey: survey) }
    let!(:question2) { create(:slider_question, anonymous_survey_similarity_uuid: 'def', survey: survey) }

    example do
      user = create(:user)

      anonymous_survey_participant1 = create(:anonymous_survey_participant, added_by_user: user)
      anonymous_survey_participant2 = create(:anonymous_survey_participant, added_by_user: user)

      question1.answers.create!(anonymous_survey_participant: anonymous_survey_participant1, params: { value: 1 })
      question2.answers.create!(anonymous_survey_participant: anonymous_survey_participant1, params: { value: 9 })

      question1.answers.create!(anonymous_survey_participant: anonymous_survey_participant2, params: { value: 2 })
      question2.answers.create!(anonymous_survey_participant: anonymous_survey_participant2, params: { value: 4 })

      results = user.combined_results_by_question

      expect(results.detect { |k, _v| k == 'abc' }.last[:average]).to eq(1.5)
      expect(results.detect { |k, _v| k == 'def' }.last[:average]).to eq(6.5)
    end
  end

  describe '#with_access_to_teams_with_any_role' do
    example do
      team1 = create(:team, name: 'team1')
      team2 = create(:team, name: 'team2')

      user1 = create(:user, c_level: false)
      user2 = create(:user, c_level: false)
      user3 = create(:user, c_level: false, system_admin: true)
      create(:user)

      TeamMember.create! role: TeamMember::Roles::LEADER, user: user1, team: team1
      TeamMember.create! role: TeamMember::Roles::MEMBER, user: user1, team: team2

      TeamMember.create! role: TeamMember::Roles::MEMBER, user: user2, team: team1

      expect(user1.with_access_to_teams_with_any_role).to contain_exactly(team1, team2)
      expect(user2.with_access_to_teams_with_any_role).to contain_exactly(team1)

      expect(user3.with_access_to_teams_with_any_role).to be_blank
    end
  end

  describe '.with_missing_recent_monthly_progress_report' do
    context 'given < 30-days old user' do
      example do
        create(:user, created_at: 1.day.ago)
        expect(described_class.with_missing_recent_monthly_progress_report).to eq([])
      end
    end

    context 'given valid user' do
      example do
        user = create(:user, created_at: 40.days.ago)

        expect(described_class.with_missing_recent_monthly_progress_report).to contain_exactly(user)

        user.user_sent_monthly_progress_reports.create! created_at: 27.days.ago

        expect(described_class.with_missing_recent_monthly_progress_report).to be_blank
      end
    end
  end

  describe '.inactive_for_last_14_days' do
    context 'given < 14-days old user' do
      example do
        create(:user, created_at: 1.day.ago)
        expect(described_class.inactive_for_last_14_days).to eq([])
      end
    end

    it 'checks for presence of recently completed challenges' do
      user1 = create(:user, created_at: 20.days.ago)
      expect(described_class.inactive_for_last_14_days).to contain_exactly(user1)

      create(:leaderbit_log, user: user1, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 7.days.ago)

      user2 = create(:user, created_at: 20.days.ago)
      create(:leaderbit_log, user: user2, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 16.days.ago)

      expect(described_class.inactive_for_last_14_days).to contain_exactly(user2)
    end

    it 'checks whether user was watching leaderbits video' do
      user1 = create(:user, created_at: 20.days.ago)
      expect(described_class.inactive_for_last_14_days).to contain_exactly(user1)

      create(:leaderbit_video_usage, user: user1, created_at: 2.days.ago)

      expect(described_class.inactive_for_last_14_days).to eq([])
    end

    it 'checks whether user wrote some entries recently' do
      user1 = create(:user, created_at: 20.days.ago)
      expect(described_class.inactive_for_last_14_days).to contain_exactly(user1)

      create(:entry, user: user1, created_at: 4.days.ago)

      #making sure we're verifying entry presence here, not leaderbit logic
      expect(LeaderbitLog.count).to be_zero
      expect(described_class.inactive_for_last_14_days).to eq([])
    end
  end

  describe '#as_email_to' do
    example do
      email = "foo@bar.com"

      user = described_class.new(name: nil, email: email)
      expect(user.as_email_to). to eq(email)

      user = described_class.new(name: 'John', email: email)
      expect(user.as_email_to). to eq("John <#{email}>")

      user = described_class.new(name: 'John Brown', email: email)
      expect(user.as_email_to). to eq("John Brown <#{email}>")
    end
  end

  describe '#destroy' do
    example do
      user1 = create(:user)
      user2 = create(:user)

      create(:organizational_mentorship, mentor_user: user1, mentee_user: user2)

      #different user entry group
      entry_group = create(:entry_group)

      create(:user_seen_entry_group, entry_group: entry_group, user: user1)
      create(:entry, user: user1)

      user1.destroy

      expect(OrganizationalMentorship.count).to eq(0)
      expect(UserSeenEntryGroup.count).to eq(0)
      expect(Entry.count).to eq(0)

      expect { user1.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # mentee is not affectedd
      expect { user2.reload }.not_to raise_error
      # seen marker is deleted but entry group is not, just double checking it
      expect { entry_group.reload }.not_to raise_error
    end
  end

  describe '#welcome_video_seen_percentage' do
    example do
      user = build(:user, welcome_video_seen_seconds: 0)
      expect(user.welcome_video_seen_percentage).to eq(0)

      user.welcome_video_seen_seconds = 13.1968
      expect(user.welcome_video_seen_percentage.round(2)).to eq(9.85)
    end
  end

  describe '#received_leaderbit_ids' do
    context 'given at time in the past' do
      example do
        user = create(:user)
        leaderbit1 = create(:leaderbit)
        leaderbit2 = create(:leaderbit)
        leaderbit3 = create(:leaderbit)
        leaderbit4 = create(:leaderbit)

        expect(user.received_uniq_leaderbit_ids).to be_blank

        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1, created_at: 4.hours.ago)
        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit2, created_at: 3.hours.ago)

        create(:leaderbit_log, user: user, leaderbit: leaderbit3, created_at: 2.hours.ago, updated_at: 2.hours.ago)
        create(:leaderbit_log, user: user, leaderbit: leaderbit4, created_at: 1.hour.ago, updated_at: 1.hour.ago)

        expect(user.reload.received_uniq_leaderbit_ids).to contain_exactly(leaderbit1.id, leaderbit2.id, leaderbit3.id, leaderbit4.id)
      end
    end

    example do
      user = create(:user)
      leaderbit1 = create(:leaderbit)
      leaderbit2 = create(:leaderbit)
      leaderbit3 = create(:leaderbit)

      expect(user.received_uniq_leaderbit_ids).to be_blank

      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1, created_at: 2.days.ago)
      expect(user.received_uniq_leaderbit_ids).to contain_exactly(leaderbit1.id)

      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit2, created_at: 1.day.ago)
      #plus already received leaderbit:
      create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1, created_at: 1.day.ago)

      expect(user.received_uniq_leaderbit_ids).to contain_exactly(leaderbit1.id, leaderbit2.id)

      #it also has to handle leaderbit logs
      create(:leaderbit_log, user: user, leaderbit: leaderbit1, updated_at: 2.seconds.ago)
      create(:leaderbit_log, user: user, leaderbit: leaderbit3, updated_at: 3.seconds.ago)

      expect(user.received_uniq_leaderbit_ids).to contain_exactly(leaderbit1.id, leaderbit2.id, leaderbit3.id)
    end
  end

  describe '#issue_new_authentication_token_and_return' do
    it 'creates new one(with valid_until property)' do
      user = create(:user)

      expect(user.authentication_token).to be_an(String)
      expect(user.authentication_token.length).to be > 5

      expect { user.issue_new_authentication_token_and_return }.to change { user.reload.authentication_token }
                                                                     .and change { EmailAuthenticationToken.where(user: user).count }.by(1)

      expect(user.reload.authentication_token).to be_an(String)
      expect(user.reload.authentication_token.length).to be > 5
    end
  end

  describe '#can_see_user_ids_as_team_member_or_team_leader' do
    context 'given team leader' do
      example do
        random_user = create(:user)
        team = FactoryBot.create(:team, organization: random_user.organization)
        TeamMember.create! user: random_user, team: team, role: TeamMember::Roles::LEADER

        user = create(:team_leader_user)
        team1 = Team.last!

        user1 = create(:user)
        expect do
          TeamMember.create! role: TeamMember::Roles::MEMBER, user: user1, team: team1
        end.to change { user.can_see_user_ids_as_team_member_or_team_leader }.from([user.id]).to([user.id, user1.id])
      end
    end

    context 'given team member' do
      example do
        user = create(:team_member_user)
        team1 = Team.first!

        user1 = create(:user)
        user2 = create(:user)
        expect do
          TeamMember.create! role: TeamMember::Roles::LEADER, user: user1, team: team1
          TeamMember.create! role: TeamMember::Roles::MEMBER, user: user2, team: team1
        end.to change { user.can_see_user_ids_as_team_member_or_team_leader }.from([user.id]).to([user.id, user1.id, user2.id])
      end
    end

    context 'given random user' do
      example do
        user = create(:user)
        expect(user.can_see_user_ids_as_team_member_or_team_leader).to be_blank
      end
    end
  end

  describe '#intercom_custom_data' do
    example do
      user = build_stubbed(:user)
      user.uuid = 'notnil12345'
      result = user.intercom_custom_data
      expect(result.keys).to include(
        :admin_page,
        :company_account_type,
        :completed_leaderbits_count,
        :email,
        :last_challenge_completed,
        :momentum,
        :name,
        :points,
        :schedule_type,
        :time_zone,
        :upcoming_challenge,
        :uuid
      )
    end
  end

  describe '#active_for_authentication' do
    subject { user.active_for_authentication? }

    context 'given regular user' do
      let(:user) { create(:user, discarded_at: nil) }

      it { is_expected.to be true }
    end

    context 'given discarded user' do
      let(:user) { create(:user, discarded_at: Time.now) }

      it { is_expected.to be false }
    end

    context 'given technical user(progress report recipient) without schedule' do
      let(:user) { create(:user, schedule: nil) }

      pending { is_expected.to be false }
    end
  end

  describe '#uuid assigning' do
    example do
      user1 = create(:user)
      expect(user1.uuid.length).to eq(7)

      user2 = create(:user)
      expect(user2.uuid.length).to eq(7)

      expect(user1.uuid).not_to eq(user2.uuid)
    end
  end

  describe '#first_challenge_to_start' do
    context 'given new user with one received leaderbit' do
      example do
        user = create(:user)
        leaderbit1 = create(:leaderbit)
        create(:leaderbit)

        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1)

        expect(user.first_leaderbit_to_start).to eq(leaderbit1)
      end
    end

    context 'given new user with multiple received leaderbit and still not seen welcome video' do
      example do
        user = create(:user)
        leaderbit1 = create(:leaderbit)
        leaderbit2 = create(:leaderbit)
        create(:leaderbit)

        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1)
        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit2)

        expect(user.first_leaderbit_to_start).to eq(leaderbit1)
      end
    end
  end

  describe '#upcoming_preemptive_leaderbits' do
    let(:schedule) { create(:schedule) }
    let(:user) { create(:user, schedule: schedule) }
    let(:added_by_user) { create(:user) }

    let(:leaderbit1) do
      create(:active_leaderbit, name: 'Preemptive Leaderbit 1').tap do |leaderbit|
        preemptive_leaderbit = user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: added_by_user
        preemptive_leaderbit.update_column :position, 0
        leaderbit
      end
    end

    let(:leaderbit2) do
      create(:active_leaderbit, name: 'Preemptive Leaderbit 2').tap do |leaderbit|
        preemptive_leaderbit = user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: added_by_user
        preemptive_leaderbit.update_column :position, 1
        leaderbit
      end
    end

    it 'checks whether user sent leaderbit time is greater than time when you added it to preemptive queue' do
      expect(user.send(:upcoming_active_preemptive_leaderbits)).to be_blank

      Timecop.freeze(6.days.ago) { leaderbit1; leaderbit2 }

      expect(user.send(:upcoming_active_preemptive_leaderbits)).to contain_exactly(leaderbit1, leaderbit2)

      Timecop.freeze(5.days.ago) { create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1) }

      expect(user.send(:upcoming_active_preemptive_leaderbits)).to contain_exactly(leaderbit2)
    end
  end

  describe '#unfinished_leaderbits_we_havent_notified_about' do
    subject { user.reload.unfinished_leaderbits_we_havent_notified_about }

    let(:schedule) { create(:schedule) }
    let(:user) { create(:user, personalized_leaderbits_algorithm_instead_of_regular_schedule: false, schedule: schedule) }

    let!(:leaderbit1) do
      create(:active_leaderbit, name: 'Leaderbit 1').tap do |leaderbit|
        leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
        leaderbit_schedule.update_column :position, 0
        leaderbit
      end
    end

    let!(:leaderbit2) do
      create(:active_leaderbit, name: 'Leaderbit 2').tap do |leaderbit|
        leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
        leaderbit_schedule.update_column :position, 1
        leaderbit
      end
    end

    context 'given existing user with uncompleted leaderbits that we havent reminded about yet' do
      let!(:user_sent_scheduled_new_leaderbit1) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit1, user: user) }
      let!(:user_sent_scheduled_new_leaderbit2) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit2, user: user) }

      let!(:leaderbit_log) { create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit2, user: user) if [true, false].sample }

      it { is_expected.to contain_exactly(leaderbit1, leaderbit2) }
    end

    context 'given existing user with uncompleted leaderbit that we havent reminded about yet' do
      let!(:user_sent_scheduled_new_leaderbit1) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit1, user: user) }
      let!(:user_sent_scheduled_new_leaderbit2) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit2, user: user) }

      let!(:leaderbit_log) { create(:leaderbit_log, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit2, user: user) }

      it { is_expected.to contain_exactly(leaderbit1) }
    end

    context 'given existing user with uncompleted leaderbit that we reminded him about' do
      let!(:user_sent_scheduled_new_leaderbit1) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit1, user: user) }
      let!(:user_sent_scheduled_new_leaderbit2) { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit2, user: user) }

      let!(:leaderbit_log) { create(:leaderbit_log, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit2, user: user) }

      let!(:user_sent_incomplete_leaderbit_reminder) { create(:user_sent_incomplete_leaderbit_reminder, resource: leaderbit1, user: user) }

      it { is_expected.to be_blank }
    end
  end

  describe '#upcoming_active_leaderbits_from_schedule' do
    subject { user.reload.upcoming_active_leaderbits_from_schedule }

    let(:schedule) { create(:schedule) }
    let(:user) { create(:user, schedule: schedule) }

    context 'given brand new user' do
      let!(:leaderbit1) do
        create(:active_leaderbit, name: 'Leaderbit 1').tap do |leaderbit|
          leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
          leaderbit_schedule.update_column :position, 0
          leaderbit
        end
      end

      let!(:leaderbit2) do
        create(:active_leaderbit, name: 'Leaderbit 2').tap do |leaderbit|
          leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
          leaderbit_schedule.update_column :position, 1
          leaderbit
        end
      end

      # let!(:preemptive_leaderbit2) do
      #   create(:active_leaderbit, name: 'Preemptive Leaderbit 2').tap do |leaderbit|
      #     preemptive_leaderbit = user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: create(:user)
      #     preemptive_leaderbit.update_column :position, 1
      #     leaderbit
      #   end
      # end

      # let!(:preemptive_leaderbit1) do
      #   create(:active_leaderbit, name: 'Preemptive Leaderbit 1').tap do |leaderbit|
      #     preemptive_leaderbit = user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: create(:user)
      #     preemptive_leaderbit.update_column :position, 0
      #     leaderbit
      #   end
      # end

      #it { is_expected.to contain_exactly(preemptive_leaderbit1, preemptive_leaderbit2, leaderbit1, leaderbit2) }
      it { is_expected.to contain_exactly(leaderbit1, leaderbit2) }
    end

    context 'given custom schedule' do
      context 'and upcoming inactive leaderbit that needs to be skipped' do
        before do
          # verify both cases eventually. user_sent_scheduled_new_leaderbits supports UserSentScheduledLeaderbit`s and LeaderbitLog`s
          if [true, false].sample
            create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit1, created_at: 2.days.ago)
          else
            create(:leaderbit_log, user: user, leaderbit: leaderbit1, status: LeaderbitLog::Statuses::IN_PROGRESS, updated_at: 2.seconds.ago)
          end
        end

        # purposely re-sorted let's
        let!(:leaderbit2) do
          create(:leaderbit, active: false, name: 'Leaderbit 2').tap do |leaderbit|
            leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
            leaderbit_schedule.update_column :position, 1
            leaderbit
          end
        end
        let!(:leaderbit1) do
          create(:active_leaderbit, name: 'Leaderbit 1').tap do |leaderbit|
            leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
            leaderbit_schedule.update_column :position, 0
            leaderbit
          end
        end
        let!(:leaderbit4) do
          create(:active_leaderbit, name: 'Leaderbit 4').tap do |leaderbit|
            leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
            leaderbit_schedule.update_column :position, 3
            leaderbit
          end
        end
        let!(:leaderbit3) do
          create(:active_leaderbit, name: 'Leaderbit 3').tap do |leaderbit|
            leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
            leaderbit_schedule.update_column :position, 2
            leaderbit
          end
        end

        it { is_expected.to contain_exactly(leaderbit3, leaderbit4) }
      end
    end
  end

  describe '#momentum' do
    subject { -> { user.reload.momentum } }

    let(:user) { create(:user) }

    let(:leaderbit) { create(:leaderbit) }

    example do
      # 1st week started
      create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, user: user, leaderbit: leaderbit, created_at: 14.days.ago, updated_at: 14.days.ago)

      create(:leaderbit_log, user: user, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit, created_at: 14.days.ago, updated_at: 14.days.ago)

      # 2 week started

      leaderbit2 = create(:leaderbit)

      create(:leaderbit_log, status: LeaderbitLog::Statuses::IN_PROGRESS, user: user, leaderbit: leaderbit2, created_at: 7.days.ago, updated_at: 7.days.ago)
      expect(subject.call).to eq(50)

      create(:leaderbit_log, user: user, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit2, created_at: 5.days.ago, updated_at: 5.days.ago)
      expect(subject.call).to eq(100)
    end
  end

  describe '#total_points' do
    describe "ensure that user's cache key is invalidated upon new point creation " do
      example do
        user = create(:user)

        expect { create(:point, value: 99, user: user) }.to change { user.reload.cache_key_with_version }
                                                              .and change { user.reload.total_points }.from(0).to(99)
      end
    end
  end

  describe '#leader_in_teams' do
    example do
      team1 = create(:team)
      organization = team1.organization
      user1 = create(:user)

      _team2 = create(:team, organization: organization)

      role_add = -> { TeamMember.create! role: TeamMember::Roles::LEADER, user: user1, team: team1 }
      leader_in_teams = -> { described_class.find(user1.id).leader_in_teams }

      expect(&role_add).to change(&leader_in_teams).from([])
                             .and change(&leader_in_teams).to [team1]
    end
  end

  describe '#employee_with_access_to_organizations' do
    example do
      organization1 = create(:organization)
      create(:organization)

      user1 = create(:user)

      role_add = -> { LeaderbitsEmployee.create! user: user1, organization: organization1 }
      employee_in_orgs = -> { described_class.find(user1.id).leaderbits_employee_with_access_to_organizations }

      expect(&role_add).to change(&employee_in_orgs).from([])
                             .and change(&employee_in_orgs).to [organization1]
    end
  end

  describe '#member_in_teams' do
    example do
      team1 = create(:team)
      organization = team1.organization
      user1 = create(:user)

      _team2 = create(:team, organization: organization)

      role_add = -> { TeamMember.create! role: TeamMember::Roles::MEMBER, user: user1, team: team1 }
      member_in_teams = -> { described_class.find(user1.id).member_in_teams }

      expect(&role_add).to change(&member_in_teams).from([])
                             .and change(&member_in_teams).to [team1]
    end
  end

  describe '#next_leaderbit_to_be_sent_at' do
    subject do
      described_class.new(time_zone: tz_name,
                          day_of_week_to_send: day_of_week_to_send,
                          hour_of_day_to_send: hour_of_day_to_send).next_leaderbit_to_be_sent_at
    end

    let(:tz_name) { 'London' }

    before do
      Timecop.travel time_now_in_user_tz
    end

    context 'when current time is sooner than weekly send time moment' do
      let(:time_now_in_user_tz) { monday_time(hour: 3, tz_name: tz_name) }
      let(:day_of_week_to_send) { 'Monday' }
      let(:hour_of_day_to_send) { 10 }

      it { is_expected.to eq( monday_time(hour: 10, tz_name: tz_name)) }
    end

    context 'when current time is later than weekly send time moment' do
      let(:time_now_in_user_tz) { saturday_time(hour: 9, tz_name: tz_name) }
      let(:day_of_week_to_send) { 'Friday' }
      let(:hour_of_day_to_send) { 17 }

      it { is_expected.to eq( 1.week.after(friday_time(hour: 17, tz_name: tz_name)) ) }
    end
  end

  describe '#current_week_leaderbit_send_time' do
    subject do
      described_class.new(time_zone: tz_name,
                          day_of_week_to_send: day_of_week_to_send,
                          hour_of_day_to_send: hour_of_day_to_send).current_week_leaderbit_send_time
    end

    let(:tz_name) { 'London' }

    before do
      Timecop.travel time_now_in_user_tz
    end

    context 'when current time is sooner than weekly send time moment' do
      let(:time_now_in_user_tz) { monday_time(hour: 3, tz_name: tz_name) }
      let(:day_of_week_to_send) { 'Monday' }
      let(:hour_of_day_to_send) { 10 }

      it { is_expected.to eq( monday_time(hour: 10, tz_name: tz_name)) }
    end

    context 'when current time is exact weekly send time moment' do
      let(:time_now_in_user_tz) { monday_time(hour: 9, tz_name: tz_name) }
      let(:day_of_week_to_send) { 'Monday' }
      let(:hour_of_day_to_send) { 9 }

      it { is_expected.to eq( monday_time(hour: 9, tz_name: tz_name)) }
    end

    context 'when current time is later than weekly send time moment' do
      let(:time_now_in_user_tz) { saturday_time(hour: 9, tz_name: tz_name) }
      let(:day_of_week_to_send) { 'Friday' }
      let(:hour_of_day_to_send) { 17 }

      it { is_expected.to eq( friday_time(hour: 17, tz_name: tz_name) ) }
    end
  end

  describe "#might_have_role_in_teams" do
    subject { current_user.might_have_role_in_teams }

    let(:organization) { current_user.organization }

    context 'given C-Level user' do
      let(:current_user) { create(:user, c_level: true) }
      let!(:team) { create(:team, organization: organization) }

      it { is_expected.to contain_exactly(team) }
    end

    context 'given team leaders' do
      let(:organization) { create(:organization) }
      let(:team) { create(:team, organization: organization) }
      let(:current_user) do
        create(:user,
               organization: organization)
          .tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::LEADER }
      end

      it { is_expected.to contain_exactly(team) }
    end

    context 'given team member' do
      let(:organization) { create(:organization) }
      let(:team) { create(:team, organization: organization) }
      let(:current_user) do
        create(:user,
               organization: organization)
          .tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::MEMBER }
      end

      it { is_expected.to eq([]) }
    end
  end
end
