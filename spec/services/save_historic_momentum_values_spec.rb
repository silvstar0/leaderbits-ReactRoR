# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SaveHistoricMomentumValues do
  describe '.call_for_all' do
    example do
      create(:user)

      expect { described_class.call_for_all }.to change(MomentumHistoricValue, :count)

      Timecop.freeze(2.days.from_now) {
        expect { described_class.call_for_all }.not_to change(MomentumHistoricValue, :count)
      }
    end
  end
end
