# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeaderbitsController, type: :controller do
  describe "GET #show" do
    login_user

    context 'c-level user' do
      render_views

      example "", login_factory: [:c_level_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        leaderbit = create(:leaderbit)
        get :show, params: { id: leaderbit.to_param }

        aggregate_failures do
          expect(response).to be_successful

          expect(response.body).to have_content(leaderbit.name)
        end
      end
    end

    context 'team member' do
      render_views

      example "before he has access to the leaderbit", login_factory: [:team_member_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        leaderbit = create(:leaderbit)
        expect {
          get :show, params: { id: leaderbit.to_param }
        }.to raise_error(Pundit::NotAuthorizedError)
      end

      example "after he has access to the leaderbit", login_factory: [:team_member_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        leaderbit = create(:leaderbit)

        if [true, false].sample
          create :user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit
        else
          @user.leaderbit_logs.create!(status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)
        end

        get :show, params: { id: leaderbit.to_param }

        expect(response).to be_successful
        expect(response.body).to have_content(leaderbit.name)
      end
    end

    context 'team leader' do
      render_views
      example "before he has access to the leaderbit", login_factory: [:team_leader_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        leaderbit = create(:active_leaderbit)

        get :show, params: { id: leaderbit.to_param }

        expect(response).to be_successful
        expect(response.body).to have_content(leaderbit.name)
      end
    end

    describe 'community entries visibility' do
      let(:organization2) { create(:organization) }

      it "displays only community-visible entries in corresponding tab", login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        user1 = create(:user, organization: @user.organization)
        user2 = create(:user, organization: organization2)

        @leaderbit = create(:active_leaderbit).tap { |l| create :user_sent_scheduled_new_leaderbit, user: @user, resource: l }

        entry1 = create(:entry, discarded_at: nil, content: 'entry1', user: user1, leaderbit: @leaderbit, visible_to_my_mentors: false, visible_to_my_peers: false, visible_to_community_anonymously: true)

        entry_group = create(:entry_group, user: user2, leaderbit: @leaderbit)
        create(:entry, discarded_at: nil, content: 'entry2', entry_group: entry_group, user: user2, leaderbit: @leaderbit, visible_to_my_mentors: true, visible_to_my_peers: false, visible_to_community_anonymously: false) #visibility: Entry::Visibility::PUBLIC_FOR_ALL)
        create(:entry, discarded_at: nil, content: 'entry3', entry_group: entry_group, user: user2, leaderbit: @leaderbit, visible_to_my_mentors: false, visible_to_my_peers: true, visible_to_community_anonymously: false) #visibility: Entry::Visibility::WITHIN_MY_ORGANIZATION)

        get :show, params: { id: @leaderbit.to_param }

        expect(assigns(:community_entries)).to contain_exactly(entry1)
      end
    end
  end

  describe "GET #start" do
    render_views

    context 'given user who already seen welcome video and received' do
      let(:user) { create(:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false) }
      let(:leaderbit) { create(:active_leaderbit) }

      before do
        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
      end

      example do
        expect {
          get :start, params: { user_email: user.email, user_token: user.authentication_token, id: leaderbit.to_param }
        }.to change { user.reload.leaderbit_logs.count }.by(1)

        expect(response).to redirect_to(leaderbit_path(leaderbit))
      end
    end
  end

  #TODO shouldn't this part be reviewed/updated?
  describe "GET /challenges/begin-first" do
    login_user

    it "when user has already received", login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      leaderbit1 = create(:leaderbit)
      create(:user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit1)

      get :begin_first_challenge

      expect(response).to redirect_to(start_leaderbit_path(leaderbit1))
    end

    it "when user has just been created and not received any leaderbits(switch_user testing?)", login_factory: [:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
      get :begin_first_challenge

      expect(response).to redirect_to(root_path)
    end
  end
end
