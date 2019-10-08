# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Engagement', type: :feature, js: true do
  let!(:schedule) { Schedule.create! name: Schedule::GLOBAL_NAME }
  let!(:leaderbit_schedule) { schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit) }

  before do
    @user = create(:user,
                   c_level: false,
                   system_admin: false,
                   name: 'current_user',
                   schedule: schedule,
                   goes_through_leader_welcome_video_onboarding_step: false,
                   goes_through_leader_strength_finder_onboarding_step: false,
                   goes_through_team_survey_360_onboarding_step: false,
                   goes_through_organizational_mentorship_onboarding_step: false)
    login_as(@user, scope: :user, run_callbacks: false)

    visit root_path
    mouseover_top_menu_item @user.first_name
  end

  context 'given one-person team/org' do
    it 'redirects user right to his individual engagement screen' do
      click_link 'Engagement'

      expect(page).to have_content('Individual Analytics')
      expect(page).to have_content('0 actions taken')

      expect(page).to have_content('focus')
      expect(page).to have_content('view profile')

      entry = create(:entry, discarded_at: nil, visible_to_my_peers: true, user: @user, leaderbit: Leaderbit.first)

      click_entries_engagement_tab

      expect(page).to have_content(entry.content)
    end
  end

  context 'given C-level user with valid organization' do
    before do
      @user.update_column :c_level, true
    end

    let!(:user2) { create(:user, organization: @user.organization) }
    let!(:progress_report_recipient) do
      u = create(:user, name: 'Recipient1', organization: @user.organization, schedule: nil)
      create(:progress_report_recipient, user: u, added_by_user: user2)
    end

    let(:leaderbit1) { Leaderbit.first! }
    let!(:leaderbit_log) { create(:leaderbit_log, user: user2, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }
    let!(:entry) { create(:entry, discarded_at: nil, visible_to_my_peers: true, user: user2, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

    context 'Values layout' do
      example do
        click_link 'Engagement'

        expect(page).to have_content('Group Analytics')

        # progress report recipients are not real users. We shouldn't display them in the list
        expect(page).not_to have_content('Recipient1')

        expect(page).to have_content('Top 2 people')
        expect(page).to have_content("ACTION  TAKEN")

        expect(page).to have_content(user2.name)
        expect(page).to have_content("#{user2.first_name} #{leaderbit1.user_action_title_suffix}")

        expect(page).to have_content('focus')
        expect(page).to have_content('view profile')
      end
    end

    context 'Entries layout' do
      example do
        click_link 'Engagement'

        click_entries_engagement_tab

        expect(page).to have_content('Total Entries')

        expect(page).to have_content(user2.name)
        expect(page).to have_content(entry.content)

        click_link 'Unread'

        expect(page).to have_content(entry.content)
      end
    end

    context 'Emails layout' do
      example do
        click_link 'Engagement'

        UserSentScheduledNewLeaderbit.create!(user: user2, leaderbit: leaderbit1)
        click_link 'Emails'

        expect(page).to have_content('New LeaderBit')
        expect(page).to have_content(leaderbit1.name)
        expect(page).to have_content('Total Entries')

        expect(page).to have_content(user2.name)
      end
    end
  end

  context 'given team leader user' do
    before do
      TeamMember.create! user: @user, team: team, role: TeamMember::Roles::LEADER
    end

    let(:team) { create(:team, organization: @user.organization) }
    let!(:team_member_user1) do
      create(:user,
             name: 'team_member_user1',
             organization: @user.organization)
        .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: team }
    end

    let!(:user2_from_same_org) { create(:user, name: 'user2_from_same_org', organization: @user.organization) }
    let(:leaderbit1) { Leaderbit.first! }
    let!(:leaderbit_log) { create(:leaderbit_log, user: team_member_user1, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }
    let!(:entry) { create(:entry, discarded_at: nil, visible_to_my_peers: true, user: team_member_user1, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

    context 'Values layout' do
      example do
        click_link 'Engagement'

        expect(page).to have_content('Group Analytics')

        expect(body).to include('current_user')
        expect(body).to include('team_member_user1')

        expect(body).not_to include('user2_from_same_org')
      end
    end
  end

  context 'given team leader member' do
    before do
      TeamMember.create! user: @user, team: team, role: TeamMember::Roles::MEMBER
    end

    let(:team) { create(:team, organization: @user.organization) }
    let!(:team_leader_user1) do
      create(:user,
             name: 'team_leader_user1',
             organization: @user.organization)
        .tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::LEADER }
    end

    let!(:user2_from_same_org) { create(:user, name: 'user2_from_same_org', organization: @user.organization) }
    let(:leaderbit1) { Leaderbit.first! }
    let!(:leaderbit_log) { create(:leaderbit_log, user: team_leader_user1, status: LeaderbitLog::Statuses::COMPLETED, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }
    let!(:entry) { create(:entry, discarded_at: nil, visible_to_my_peers: true, user: team_leader_user1, leaderbit: leaderbit1, created_at: 2.seconds.ago, updated_at: 2.seconds.ago) }

    context 'Values layout' do
      example do
        click_link 'Engagement'

        expect(page).to have_content('Group Analytics')

        expect(body).to include('current_user')
        expect(body).to include('team_leader_user1')

        expect(body).not_to include('user2_from_same_org')
      end
    end
  end

  context 'given mentor' do
    it 'displays list of entries of my mentees' do
      user2 = create(:user, name: 'Mentee user')
      OrganizationalMentorship.create! mentor_user: @user, mentee_user: user2, accepted_at: Time.now
      entry = create(:entry, discarded_at: nil, leaderbit: Leaderbit.first!, user: user2, visible_to_my_mentors: true)
      create(:leaderbit_log, leaderbit: Leaderbit.first!, user: user2, status: LeaderbitLog::Statuses::COMPLETED, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)

      click_link 'Engagement'

      expect(page).to have_content(' Analytics')

      select('People I Mentor', from: 'request_type')

      click_entries_engagement_tab

      expect(page).to have_content('Total Entries')
      expect(page).to have_content(user2.name)
      expect(page).to have_content(entry.content)
    end
  end

  context 'given mentee' do
    it 'displays my own entry and lists my mentor in *All people*' do
      user2 = create(:user, name: 'Mentor user')
      OrganizationalMentorship.create! mentor_user: user2, mentee_user: @user, accepted_at: Time.now
      entry = create(:entry, discarded_at: nil, leaderbit: Leaderbit.first!, user: @user, visible_to_my_mentors: true)
      create(:leaderbit_log, leaderbit: Leaderbit.first!, user: @user, status: LeaderbitLog::Statuses::COMPLETED, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)

      click_link 'Engagement'

      expect(page).to have_content(@user.name)
      expect(page).to have_content(user2.name)
      expect(page).to have_content('Top 2 people')

      click_entries_engagement_tab

      expect(page).to have_content('Total Entries')
      expect(page).to have_content(entry.content)
    end
  end

  context 'given team member in different teams' do
    pending
  end

  def click_entries_engagement_tab
    # any simple way to remove sleep call?
    sleep 1

    #click_link 'Entries' ambigious links from recent update so workaround:
    all('a').select { |elt| elt.text == "Entries" }.last.click
  end
end
