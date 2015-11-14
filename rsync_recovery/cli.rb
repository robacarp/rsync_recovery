require 'pp'
require 'byebug'

require_relative 'cli/analyze'
require_relative 'cli/drop'
require_relative 'cli/search'

module RsyncRecovery
  module CLI
    class Base
      def self.run
        start_time = Time.now
        # Boot
        options = Options.parse
        options.setting :database
        Database.instance filename: options.setting(:database).value

        # Database schema wrangling
        Drop.drop        if options.flagged? :drop
        Database.instance.schema_load

        # Load up ORM
        require_relative 'hashed_file'
        require_relative 'edge'

        # Follow orders
        Search.new(options).search    if options.flagged? :search
        Analyze.new(options).analyze  if options.flagged? :analyze
        merge            if options.flagged? :merge

        end_time = Time.now
        puts "Run time: #{end_time - start_time}s"
      rescue RuntimeError => e
        puts e.message
      end

      def merge
      end
    end
  end
end
