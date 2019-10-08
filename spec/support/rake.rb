# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    #NOTE: it is important to load it just once, otherwise tasks could be executed multiple times
    Rake.load_rakefile Rails.root.join('Rakefile')
  end
end
