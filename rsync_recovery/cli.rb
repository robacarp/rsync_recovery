require 'pp'
require 'byebug'

require_relative 'cli/analyze'
require_relative 'cli/drop'
require_relative 'cli/search'

module RsyncRecovery
  module CLI
    class Base
      def self.run
        # Boot
        Options.parse
        Database.instance filename: Options.settings[:database]

        # Database schema wrangling
        Drop.drop        if Options.flagged? :drop
        Database.instance.schema_load

        # Load up ORM
        require_relative 'hashed_file'
        require_relative 'edge'

        # Follow orders
        Search.search    if Options.flagged? :search
        Analyze.analyze  if Options.flagged? :analyze
        merge            if Options.flagged? :merge

      rescue RuntimeError => e
        puts e.message
      end

      def merge
      end
    end
  end
end
