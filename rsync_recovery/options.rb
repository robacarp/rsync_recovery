module RsyncRecovery
  class Options
    # hacky docopty class because docopt wasn't working.
    # report bugs to 
    class << self
      def usage
        <<-USAGE
Rsync Recovery.

For when you accidentally copy your files all over the place and need a cleanup.

Usage:
  #{BINARY} --search <directory> [options]
  #{BINARY} --analyze
  #{BINARY} --drop                                Start from fresh database.
  #{BINARY} --merge <file1.db> <file2.db>         Not implemented.
  #{BINARY} --help, -h                            This, help.
  #{BINARY} --version, -v                         Version info.

Options:
  --no-recurse           Not implemented.
  --debug                Be more verbose.
  --force-rehash         Don't get smart and bypass known files. Rehash everything.
  --data-file=<file.db>  Point to a specific data store. Useful for running the
                         script on several machines. (default: #{BINARY}.db)

Rsync Recovery.
        USAGE
      end

      def defaults
        [
          Option.new(text: 'recursive=true'),
          Option.new(text: "database").tap {|o| o.references << "#{BINARY}.db"}
        ]
      end

      # options without =
      def flags
        guard
        @instance.flags
      end

      # options with =
      def settings
        guard
        @instance.settings
      end

      # options which aren't in the doc, eg files
      def references
        guard
        @instance.references
      end

      def flagged? name
        guard
        @instance.flagged? name
      end

      def guard
        if ! defined? @options
          raise RuntimeError, 'CLI Options not parsed yet'
        end
      end

      def parse
        return @instance if @instance

        @instance = new
        @instance.parse
        @instance.freeze

        # enforce_action
        # builtins
      end

      def enforce_action
        one_of = [ :search, :analyze, :merge ]
        unless (one_of & flags).any?
          fail usage
        end
      end

      def builtins
        if @options.flagged? :help, :h
          fail usage
        end

        if @options.flagged? :version, :v
          fail "#{BINARY} #{VERSION}"
        end
      end
    end

    def initialize
      @options = []
    end

    def parse
      ARGV.each do |arg|
        if arg[0] == '-'
          @options << Option.parse(arg)
        elsif @options.any?
          @options.last.references << arg
        else
          fail "No option given for reference #{arg}"
        end

        validate @options.last
      end
    end

    def validate option
      @possibilities ||= self.class.usage.scan(/\W-{1,2}[a-z-]+/).map(&:strip)

      if ! @possibilities.include? option.name
        fail "Invalid option '#{option.name}'"
      end
    end

    def flagged? *flags
      @options.select {|opt| opt.type == :flag}
              .any? do |flag|
                flags.include? flag
              end
    end

    def setting name
      @options.find { |opt| opt.name == name }
    end
  end
end
