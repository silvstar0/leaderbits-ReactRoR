# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PreemptiveLeaderbitPolicy do
  subject { described_class.new(user, record) }

  describe '#create' do
    let(:record) { [:admin, PreemptiveLeaderbit] }

    context 'given system admin' do
      let!(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:create) }
    end

    context 'given employee' do
      let!(:user) do
        create(:user).tap { |u| LeaderbitsEmployee.create! user: u, organization: Organization.first! }
      end

      it { is_expected.to permit_action(:create) }
    end

    context 'given random user' do
      let!(:user) { create(:user) }

      it { is_expected.to forbid_action(:create) }
    end
  end

  describe '#sort' do
    let(:record) { [:admin, PreemptiveLeaderbit] }

    context 'given system admin' do
      let!(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:sort) }
    end

    context 'given employee' do
      let!(:user) do
        create(:user)
          .tap { |u| LeaderbitsEmployee.create! user: u, organization: Organization.first! }
      end

      it { is_expected.to permit_action(:sort) }
    end

    context 'given random user' do
      let!(:user) { create(:user) }

      it { is_expected.to forbid_action(:sort) }
    end
  end
end
