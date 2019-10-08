# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'release.rake' do
  example do
    expect { Rake::Task['post_release'].execute }.not_to raise_error
  end
end
