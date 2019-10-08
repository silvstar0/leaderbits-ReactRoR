# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PointSystem do
  describe '#total_levels_count' do
    subject { described_class.new(User.new).parse!.total_levels_count }

    it { is_expected.to eq(53) }
  end
end
