# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include Pundit

  describe '#pluralize_without_count(count, noun, text = nil)' do
    example do
      expect { helper.pluralize_without_count(0, 'Leader') }.to raise_error(ArgumentError)
      expect(helper.pluralize_without_count(1, 'Leader')).to eq('Leader')
      expect(helper.pluralize_without_count(2, 'Leader')).to eq('Leaders')
    end
  end
end
