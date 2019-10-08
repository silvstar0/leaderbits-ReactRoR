# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "current user level num" do |name|
  subject { helper.current_level_num(user) }

  let(:user) { OpenStruct.new(total_points: total_points) }

  it { is_expected.to eq(name) }
end

RSpec.shared_examples "next user level num" do |name|
  subject { helper.next_level_num(user) }

  let(:user) { OpenStruct.new(total_points: total_points) }

  it { is_expected.to eq(name) }
end

RSpec.shared_examples "max points for current level" do |points|
  subject { helper.max_points_for_current_level(user) }

  let(:user) { OpenStruct.new(total_points: total_points) }

  it { is_expected.to eq(points) }
end

RSpec.describe PointSystemHelper, type: :helper do
  describe '#current_level_percent_completed' do
    context 'given Level 1 user with 3 points' do
      subject { helper.current_level_percent_completed(user) }

      let(:user) { create(:user) }

      before do
        leaderbit = create(:leaderbit)
        create(:point, user: user, value: 1, pointable: leaderbit)
        create(:point, user: user, value: 2, pointable: leaderbit)
      end

      it { is_expected.to eq(3 / 230.0 * 100) }
    end
  end

  context 'given 1 user' do
    [0, 99, 230].each do |i|
      describe '#current_level_num' do
        include_examples "current user level num", 1 do
          let(:total_points) { i }
        end
      end

      describe '#next_level_num' do
        include_examples "next user level num", 2 do
          let(:total_points) { i }
        end
      end

      describe '#max_points_for_current_level' do
        include_examples "max points for current level", 230 do
          let(:total_points) { i }
        end
      end
    end
  end

  context 'given 2 users' do
    [231, 459].each do |i|
      describe '#current_level_num' do
        include_examples "current user level num", 2 do
          let(:total_points) { i }
        end
      end

      describe '#next_level_num' do
        include_examples "next user level num", 3 do
          let(:total_points) { i }
        end
      end

      describe '#max_points_for_current_level' do
        include_examples "max points for current level", 460 do
          let(:total_points) { i }
        end
      end
    end
  end

  context 'given 53 users' do
    [23_116, 23_400, 23_920].each do |i|
      describe '#current_level_num' do
        include_examples "current user level num", 53 do
          let(:total_points) { i }
        end
      end

      describe '#max_points_for_current_level' do
        include_examples "max points for current level", 23_920 do
          let(:total_points) { i }
        end
      end
    end
  end
end
