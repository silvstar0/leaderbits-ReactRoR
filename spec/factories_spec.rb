# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'validate FactoryBot factories' do
  FactoryBot.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { build(factory.name) }

      it "is valid" do
        is_valid = subject.valid?
        expect(is_valid).to be_truthy, subject.errors.full_messages.join(',')
      end
    end
  end
end
