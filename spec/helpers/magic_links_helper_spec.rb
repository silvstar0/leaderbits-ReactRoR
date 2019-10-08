# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MagicLinksHelper, type: :helper do
  describe '#masked_email' do
    def on_email(email)
      helper.masked_email(User.new(email: email))
    end

    example do
      expect(on_email('john.brown@example.com')).to eq('j********n@example.com')
      expect(on_email('a@example.com')).to eq('*@example.com')
      expect(on_email('ab@example.com')).to eq('*b@example.com')
      expect(on_email('abc@example.com')).to eq('a*c@example.com')
      expect(on_email('joel@twitter.com')).to eq('j**l@twitter.com')
    end
  end
end
