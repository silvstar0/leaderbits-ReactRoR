# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntriesController, type: :controller do
  describe "GET #show" do
    login_user
    render_views

    context 'when signed in as admin user' do
      example '', login_factory: :system_admin_user do
        entry = create(:entry, discarded_at: nil)

        get :show, params: { id: entry.id }

        expect(response).to redirect_to(entry.entry_group)
      end
    end
  end

  describe "POST #create" do
    login_user

    let(:valid_attributes) { { content: 'Lorem ipsum' } }

    context "with valid params" do
      let(:leaderbit) { create(:leaderbit) }

      before { raise unless @user.total_points.zero? }

      context 'first ReflectDB entry creation' do
        example 'it displays achievement unlocked message', login_factory: :team_member_user do
          unobtrusive_flash = double('unobtrusive_flash')
          expect(unobtrusive_flash).to receive(:achievement).with(id: Rails.configuration.achievements.first_completed_challenge__on_leaderbits_show)
          expect(unobtrusive_flash).to receive(:notify) # points
          allow(controller).to receive(:unobtrusive_flash).and_return(unobtrusive_flash)

          create(:user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit)

          # sets proper visibility, assigns points
          expect {
            post :create, params: { leaderbit_id: leaderbit.id, entry: valid_attributes }, xhr: true
          }.to change(Entry, :count).to(1)
                 .and change { @user.reload.total_points }.by_at_least(1)
        end
      end

      context 'non-first ReflectDB entry creation' do
        example 'does not display achievement unlocked message', login_factory: :team_member_user do
          create(:user_sent_scheduled_new_leaderbit, user: @user, resource: leaderbit)
          create(:entry, user: @user, leaderbit: leaderbit, discarded_at: nil)

          unobtrusive_flash = double('unobtrusive_flash')
          expect(unobtrusive_flash).not_to receive(:achievement)
          expect(unobtrusive_flash).not_to receive(:notify) # points
          allow(controller).to receive(:unobtrusive_flash).and_return(unobtrusive_flash)

          expect {
            post :create, params: { leaderbit_id: leaderbit.id, entry: valid_attributes }, xhr: true
          }.to change(Entry, :count).from(1).to(2)
        end
      end
    end
  end

  describe "POST #toggle_like" do
    login_user
    render_views

    example '', login_factory: :team_member_user do
      entry = create(:entry, discarded_at: nil)

      UserSeenEntryGroup.create! entry_group: entry.entry_group, user: @user

      expect {
        post :toggle_like, params: { id: entry.id }, xhr: true
      }.to change{ entry.reload.likes_score }.to(1)
             .and change { ActsAsVotable::Vote.count }.to(1)
                    .and change { entry.get_likes.count }.to(1)
      expect(ActsAsVotable::Vote.count).to eq(1)

      expect(assigns(:svg_class)).to eq('liked')

      expect {
        post :toggle_like, params: { id: entry.id }, xhr: true
      }.to change{ entry.reload.likes_score }.to(0)
             .and change { entry.get_likes.count }.from(1).to(0)
      expect(entry.get_dislikes.count).to eq(0)
      expect(ActsAsVotable::Vote.count).to eq(0)

      expect(assigns(:svg_class)).to eq('disliked')
    end
  end

  describe 'DELETE #destroy' do
    login_user

    context 'given the only entry in leaderbit for user' do
      example '', login_factory: :user do
        entry = create(:entry, user: @user, discarded_at: nil)

        expect{
          delete :destroy, params: { id: entry.id, leaderbit_id: entry.leaderbit_id }, xhr: true
        }.to change { @user.entries.kept.count }.by(-1)
      end
    end

    context 'given 2nd entry in leaderbit for user' do
      let(:leaderbit) { create(:leaderbit) }

      example '', login_factory: :user do
        entry_group = create(:entry_group, leaderbit: leaderbit, user: @user)

        entry1 = create(:entry, leaderbit: leaderbit, user: @user, entry_group: entry_group, discarded_at: nil)
        create(:entry, leaderbit: leaderbit, user: @user, entry_group: entry_group, discarded_at: nil)

        expect{
          delete :destroy, params: { id: entry1.id, leaderbit_id: entry1.leaderbit_id }, xhr: true
        }.to change { @user.entries.kept.count }.by(-1)
      end
    end

    context 'given 2nd entry in leaderbit for user' do
      let(:leaderbit) { create(:leaderbit) }
      let(:user) { create(:user) }

      it 'prevents delete by unauthorized user', login_factory: :user do
        entry_group = create(:entry_group, leaderbit: leaderbit, user: user)

        entry1 = create(:entry, leaderbit: leaderbit, user: user, entry_group: entry_group)
        create(:entry, leaderbit: leaderbit, user: user, entry_group: entry_group)

        expect{
          delete :destroy, params: { id: entry1.id, leaderbit_id: entry1.leaderbit_id }, xhr: true
        }.to raise_error(StandardError)
      end
    end
  end
end
