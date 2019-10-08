# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BoomerangsController, type: :controller do
  describe "POST #create" do
    login_user

    let(:text) { 'Lorem ipsum' }

    context "with valid params" do
      let(:leaderbit) { create(:leaderbit) }

      example '', login_factory: :system_admin_user do
        type = BoomerangLeaderbit::Types::ALL.sample

        expect {
          post :create, params: { leaderbit_id: leaderbit.to_param, boomerang: { type: type } }, xhr: true
        }.to change { BoomerangLeaderbit&.last&.type }.from(nil).to(type)
      end
    end
  end
end
