# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntryGroupsController, type: :controller do
  describe "GET #index" do
    login_user
    render_views

    context 'when signed in as admin user' do
      example 'it displays only kept entries', login_factory: :system_admin_user do
        leaderbit = create(:active_leaderbit)

        entry1 = create(:entry, leaderbit: leaderbit, discarded_at: nil)
        entry2 = create(:entry, leaderbit: leaderbit, discarded_at: Time.now)

        get :index

        expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)

        expect(response).to be_successful
        expect(response.body).to have_content(entry1.content)

        expect(response.body).not_to have_content(entry2.content)
      end
    end

    # context 'when signed in as employee' do
    #   example '', login_factory: :employee_user do
    #     expect(@user.leaderbits_employee_with_access_to_organizations.count).to eq(1)
    #     organization = @user.leaderbits_employee_with_access_to_organizations.first
    #
    #     user1 = create(:user, organization: organization)
    #     entry1 = create(:entry, user: user1)
    #     entry2 = create(:entry, discarded_at: nil)
    #
    #     get :index
    #
    #     expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group, entry2.entry_group)
    #
    #     expect(response).to be_successful
    #     expect(response.body).to have_content(entry1.content)
    #     expect(response.body).to have_content(entry2.content)
    #   end
    # end

    context 'when signed in as C-level user user' do
      example '', login_factory: [:c_level_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        organization = @user.organization

        user1 = create(:user, organization: organization)
        expect(Organization.count).to eq(1)

        entry1 = create(:entry, content: 'entry1', user: user1, visible_to_my_peers: true, discarded_at: nil)
        create(:entry, content: 'entry2', visible_to_my_peers: true, discarded_at: nil)

        get :index

        expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)

        expect(response).to be_successful
        expect(response.body).to have_content(entry1.content)
      end
    end

    context 'when signed in as team leader' do
      example '', login_factory: [:team_leader_user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false] do
        team = Team.first!

        user = create(:user)
                 .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: team }
        entry1 = create(:entry, user: user, content: 'entry1', visible_to_my_peers: true, discarded_at: nil)

        create(:entry, content: 'other user entry', discarded_at: nil)

        get :index

        expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)

        expect(response).to be_successful
        expect(response.body).to have_content(entry1.content)
      end
    end
  end

  # describe "GET #unread" do
  #   login_user
  #   render_views
  #
  #   context 'when signed in as admin user' do
  #     example '', login_factory: :system_admin_user do
  #       entry1 = create(:entry, content: 'foo')
  #       entry2 = create(:entry, content: 'bar')
  #
  #       UserSeenEntryGroup.create! user: @user, entry_group: entry2.entry_group
  #
  #       get :unread
  #
  #       expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)
  #
  #       expect(response).to be_successful
  #       expect(response.body).to have_content(entry1.content)
  #       expect(response.body).not_to have_content(entry2.content)
  #     end
  #   end
  #
  #   context 'when signed in as C-level user user' do
  #     example '', login_factory: :c_level_user do
  #       organization = @user.organization
  #
  #       user1 = create(:user, organization: organization)
  #       expect(Organization.count).to eq(1)
  #
  #       entry1 = create(:entry, visible_to_my_peers: true, content: 'entry1', user: user1)
  #       entry2 = create(:entry, visible_to_my_peers: true, content: 'entry2', user: user1)
  #
  #       UserSeenEntryGroup.create! user: @user, entry_group: entry2.entry_group
  #
  #       create(:entry, content: 'entry3')
  #
  #       get :unread
  #
  #       expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)
  #
  #       expect(response).to be_successful
  #       expect(response.body).to have_content(entry1.content)
  #     end
  #   end
  #
  #   context 'when signed in as team leader' do
  #     example '', login_factory: :team_leader_user do
  #       team = Team.first!
  #
  #       user = create(:user)
  #                .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: team }
  #       entry1 = create(:entry, visible_to_my_peers: true, user: user, content: 'entry1')
  #
  #       entry2 = create(:entry, visible_to_my_peers: true, user: user, content: 'entry1')
  #
  #       UserSeenEntryGroup.create! user: @user, entry_group: entry2.entry_group
  #
  #       get :unread
  #
  #       expect(assigns(:entry_groups)).to contain_exactly(entry1.entry_group)
  #
  #       expect(response).to be_successful
  #       expect(response.body).to have_content(entry1.content)
  #     end
  #   end
  # end

  describe "POST #mark_as_read" do
    login_user
    render_views

    it 'marks entry as read', login_factory: :system_admin_user do
      entry_group = create(:entry_group)

      expect {
        post :mark_as_read, params: { id: entry_group.id }, xhr: true
      }.to change{ UserSeenEntryGroup.where(user: @user, entry_group: entry_group).count }.from(0).to(1)
    end
  end

  describe "GET #show" do
    login_user
    render_views

    context 'when signed in as admin user' do
      example '', login_factory: :system_admin_user do
        entry = create(:entry, discarded_at: nil)
        entry_group = entry.entry_group
        parent_reply = create(:entry_reply, entry: entry)
        create(:entry_reply, entry: entry, parent_reply_id: parent_reply.id)

        get :show, params: { id: entry_group.id }

        expect(assigns(:entry_group)).to eq(entry_group)

        expect(response).to be_successful
        # expect(response.body).to have_content(parent_reply.content)
        # expect(response.body).to have_content(parent_reply.content)
        expect(response.body).to have_content('Read LeaderBit')
        expect(response.body).to have_content(entry.content)
      end
    end
  end
end
