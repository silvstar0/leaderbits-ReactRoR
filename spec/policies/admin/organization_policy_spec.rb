# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::OrganizationPolicy do
  subject { described_class.new(user, record) }

  describe '#destroy' do
    let(:record) { create(:organization) }

    context 'when system admin' do
      let!(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:destroy) }
    end

    context 'when random user' do
      let!(:user) { create(:user) }

      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
