# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractDetailsOnIpAddresses do
  context 'given unregistered user ip address' do
    example do
      create(:user, last_sign_in_ip: '1.1.1.1')

      expect { described_class.call }.to have_enqueued_job(ExtractDetailsOnIpAddressJob).with('1.1.1.1')
    end

    example do
      create(:user, current_sign_in_ip: '2.2.2.2')

      expect { described_class.call }.to have_enqueued_job(ExtractDetailsOnIpAddressJob).with('2.2.2.2')
    end
  end

  context 'given already tracked user ip address' do
    example do
      create(:user, current_sign_in_ip: '2.2.2.2')

      IpAddressDetail.create! ip: '2.2.2.2'

      expect { described_class.call }.not_to have_enqueued_job(ExtractDetailsOnIpAddressJob)
    end
  end
end
