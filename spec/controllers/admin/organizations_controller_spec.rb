# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OrganizationsController, type: :controller do
  #TODO-low move to capybara spec?
  describe "GET #show" do
    login_user

    render_views
    example "", login_factory: :system_admin_user do
      @organization = create(:organization, name: 'simple name without special chars')

      get :show, params: { id: @organization.to_param }

      expect(response).to be_successful
      expect(response.body).to include(@organization.name)
    end
  end

  #TODO-low move to capybara spec?
  describe "DELETE #destroy" do
    login_user
    render_views

    example "", login_factory: :system_admin_user do
      organization = create(:organization)

      expect {
        delete :destroy, params: { id: organization.to_param }
      }.to change { organization.reload.discarded_at }.from(nil)
    end
  end
end
