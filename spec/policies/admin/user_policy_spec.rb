# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserPolicy do
  subject { described_class.new(user, record) }

  describe '#update' do
    let(:organization) { create(:organization) }

    context 'given employee' do
      let(:organization1) { create(:organization) }
      let!(:user) do
        create(:user,
               organization: organization)
          .tap { |u| LeaderbitsEmployee.create! user: u, organization: organization1 }
      end

      context 'and your org user' do
        let(:record) { create(:user, organization: organization1) }

        it { is_expected.to permit_action(:update) }
      end

      context 'and not your org user' do
        let(:record) { create(:user) }

        it { is_expected.to forbid_action(:update) }
      end

      context 'and yourself record' do
        let(:record) { user }

        it { is_expected.to forbid_action(:update) }
      end
    end
  end

  describe '#switch_user_as' do
    context 'given system admin' do
      let!(:user) { create(:system_admin_user) }

      context 'and regular user' do
        let(:record) { create(:user) }

        it { is_expected.to permit_action(:switch_user_as) }
      end

      context 'and another system admin user' do
        let(:record) { create(:system_admin_user) }

        it { is_expected.to permit_action(:switch_user_as) }
      end
    end

    context 'given employee' do
      let(:organization) { create(:organization) }
      let!(:user) do
        create(:user,
               organization: organization)
          .tap { |u| LeaderbitsEmployee.create! user: u, organization: organization }
      end

      context 'and your org user' do
        let(:record) { create(:user, organization: organization) }

        it { is_expected.to permit_action(:switch_user_as) }
      end

      context 'and system admin ' do
        let(:record) { create(:system_admin_user, organization: organization) }

        it { is_expected.to forbid_action(:switch_user_as) }
      end

      context 'and not your org user' do
        let(:record) { create(:user) }

        it { is_expected.to forbid_action(:switch_user_as) }
      end
    end

    context 'given regular user' do
      let!(:user) { create(:user) }

      context 'and regular user' do
        let(:record) { create(:user, organization: user.organization) }

        it { is_expected.to forbid_action(:switch_user_as) }
      end
    end

    context 'given unsigned in user' do
      let!(:user) { nil }

      context 'and regular user user' do
        let(:record) { create(:user) }

        it { is_expected.to forbid_action(:switch_user_as) }
      end
    end

    describe '#toggle_discard' do
      let(:record) { create(:user) }

      context 'when system admin' do
        let!(:user) { create(:system_admin_user) }

        it { is_expected.to permit_action(:toggle_discard) }
      end

      context 'when random user' do
        let!(:user) { create(:user) }

        it { is_expected.to forbid_action(:toggle_discard) }
      end
    end
  end
end
