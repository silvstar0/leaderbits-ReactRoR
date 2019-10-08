# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HomeController, type: :controller do
  describe "GET #root" do
    login_user
    render_views

    example '', login_factory: :system_admin_user do
      get :root

      expect(response.body).to include('Admin Dashboard')
    end
  end
end
