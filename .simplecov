SimpleCov.start 'rails' do
  add_group 'Pundit Policies', 'app/policies'
  add_group 'Decorators', 'app/decorators'
  add_group 'Services', 'app/services'
  add_group 'Rakefile', 'Rakefile'
  add_group 'ActionCable', 'app/channels'
  coverage_dir File.join(ENV['CIRCLE_WORKING_DIRECTORY'], 'tmp', 'reports') if ENV['CI'] || ENV['COVERAGE']
end if ENV['CI'] || ENV['COVERAGE']
