# frozen_string_literal: true

module ControllerMacros
  def login_user
    before do |example|
      @request.env['devise.mapping'] = Devise.mappings[:user]

      factory_name = example.metadata.fetch(:login_factory) { raise "Provide spec with :login_factory" }
      @user = FactoryBot.create(*factory_name)
      sign_in @user
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros
  include Warden::Test::Helpers

  config.after do
    Warden.test_reset!
  end
end
