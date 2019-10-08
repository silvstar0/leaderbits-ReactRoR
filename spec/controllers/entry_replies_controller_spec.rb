# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntryRepliesController, type: :controller do
  #TODO-low move to capybara spec?
  describe "PUT #update" do
    login_user

    context "with valid params" do
      let(:entry) { create(:entry, discarded_at: nil) }

      example '', login_factory: :system_admin_user do
        entry_reply = create(:entry_reply, user: @user, entry: entry)

        expect {
          put :update, params: { id: entry_reply.id, entry_reply: { entry_id: entry.id, content: 'upd' } }, xhr: true
        }.to change { entry_reply.reload.content }.to('upd')
      end
    end
  end

  #TODO-low move to capybara spec?
  describe "DELETE #destroy" do
    login_user

    context "with valid params" do
      let(:entry) { create(:entry, discarded_at: nil) }

      example '', login_factory: :system_admin_user do
        entry_reply = create(:entry_reply, user: @user, entry: entry)

        expect {
          delete :destroy, params: { id: entry_reply.id }, xhr: true
        }.to change(EntryReply, :count).to(0)
      end
    end
  end

  #NOTE: do not remove this spec. That's the only place where we check liking from email links
  describe "GET #toggle_like" do
    render_views

    #TODO figure out whether user can like it from email without going through the welcome video first

    context 'given user who received reply on his entry' do
      let(:user) { create(:user, goes_through_leader_welcome_video_onboarding_step: false, goes_through_leader_strength_finder_onboarding_step: false, goes_through_team_survey_360_onboarding_step: false, goes_through_organizational_mentorship_onboarding_step: false) }
      let(:entry) { create(:entry, user: user) }
      let(:leaderbit) { entry.leaderbit }
      let(:entry_reply) { create(:entry_reply, entry: entry) }

      example do
        expect {
          get :toggle_like, params: { user_email: user.email, user_token: user.authentication_token, id: entry_reply.to_param }
        }.to change { ActsAsVotable::Vote.count }.to(1)

        expect(response).to redirect_to(entry_group_url(entry_reply.entry.entry_group.to_param, anchor: "entry_reply_#{entry_reply.id}"))
      end
    end
  end
end
