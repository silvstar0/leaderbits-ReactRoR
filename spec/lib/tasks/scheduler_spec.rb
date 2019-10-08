# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rake scheduler tasks' do
  example do
    expect { Rake::Task['hour_scheduler_task'].execute }.not_to raise_error
  end

  example do
    expect { Rake::Task['ten_minute_scheduler_task'].execute }.not_to raise_error
  end

  example do
    expect { Rake::Task['day_scheduler_task'].execute }.not_to raise_error
  end
end
