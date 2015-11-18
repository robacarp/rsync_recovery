require 'pp'
require 'byebug'

require_relative 'cli/analyze'
require_relative 'cli/drop'
require_relative 'cli/search'

module RsyncRecovery
  module CLI
    class Base
      USAGE = <<-USAGE
Rsync Recovery.

For when you accidentally copy your files all over the place and need a cleanup.

Usage:
  --search <directory> [options]
  --analyze
  --drop                                Start from fresh database.
  --merge <file1.db> <file2.db>         Not implemented.
  --help, -h                            This, help.
  --version, -v                         Version info.

Options:
  --no-recurse           Not implemented.
  --debug                Be more verbose.
  --force-rehash         Don't get smart and bypass known files. Rehash everything.
  --data-file=<file.db>  Point to a specific data store. Useful for running the
                         script on several machines. (default: #{BINARY}.db)

Rsync Recovery.
      USAGE

      def defaults
        ['--recursive',"--database=#{BINARY}.db"]
      end

      def run
        start_time = Time.now
        # Boot
        options = Options.new(usage: USAGE, defaults: defaults)
        options.parse ARGV
        options.try_to_help
        options.enforce_one_of :search, :analyze, :merge

        Database.connect "sqlite://#{options.setting(:database)}"
        # Database schema wrangling
        Drop.drop                     if options.flagged? :drop
        Database.instance.schema_load

        # Follow orders
        Search.new(options).search    if options.flagged? :search
        Analyze.new(options).analyze  if options.flagged? :analyze
        # merge            if options.flagged? :merge

        end_time = Time.now
        puts "Run time: #{end_time - start_time}s"
      rescue RuntimeError => e
        puts e.message
      end
    end
  end
end
