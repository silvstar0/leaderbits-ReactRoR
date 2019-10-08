# frozen_string_literal: true

class InstallTrigram < ActiveRecord::Migration[5.0]
  def self.up
    say_with_time("Initialize pg_trgm postgres extension") do
      ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")
    end
  end

  def self.down
    say_with_time("Drop pg_trgm postgres extension") do
      ActiveRecord::Base.connection.execute("DROP EXTENSION pg_trgm;")
    end
  end
end
