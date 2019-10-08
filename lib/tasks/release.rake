# frozen_string_literal: true

desc "Print post-release checklist"
task :print_post_release_checklist do |_rake_task|
  #next unless Rails.env.production?
  rake_puts Rails.env.to_s
  rake_puts "***** POST-RELEASE-CHECKLIST.md *****"
  begin
    file_content = File.read File.join(File.dirname(__FILE__), "../../POST-RELEASE-CHECKLIST.md")
    rake_puts file_content
    rake_puts "***** POST-RELEASE-CHECKLIST.md *****"
  rescue StandardError => e
    rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  end
end

desc "Heroku post-release task"
task post_release: ['db:migrate', 'print_post_release_checklist'] do |rake_task|
  rake_puts "#{rake_task.name} has been called"
end
