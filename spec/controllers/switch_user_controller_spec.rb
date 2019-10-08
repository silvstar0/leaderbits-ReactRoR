# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SwitchUserController, type: :controller do
  context 'given unsigned in user' do
    example do
      user = create(:user, leaderbits_sending_enabled: false)
      expect { get :set_current_user, params: { scope_identifier: "user_#{user.id}" } }.to raise_error(ActionController::RoutingError, "Do not try to hack us.")
    end
  end

  context 'given signed in as regular user' do
    login_user
    example '', login_factory: [:user, leaderbits_sending_enabled: false] do
      user = create(:user)
      expect { get :set_current_user, params: { scope_identifier: "user_#{user.id}" } }.to raise_error(ActionController::RoutingError, "Do not try to hack us.")
    end
  end

  context 'given signed in as system admin' do
    login_user
    example '', login_factory: :system_admin_user do
      user = create(:user)
      expect { get :set_current_user, params: { scope_identifier: "user_#{user.id}" } }.not_to raise_error
      expect(response).to be_redirect
    end
  end
end
