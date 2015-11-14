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
      end

      def defaults
        [
          Option.new(text: '--recursive'),
          Option.new(text: "--database=#{BINARY}.db")
        ]
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

    attr_reader :options

    def initialize
      @options = self.class.defaults
    end

    def parse
      ARGV.each do |arg|
        if arg[0] == '-'
          @options << Option.parse(arg)
          validate @options.last
        elsif @options.any?
          @options.last.references << arg
        else
          fail "No option given for reference #{arg}"
        end
      end
    end

    def validate option
      @possibilities ||= self.class.usage.scan(/\W-{1,2}[a-z-]+/).map(&:strip)

      match = @possibilities.index {|name| option.match name}

      unless match
        fail "Invalid option '#{option.name}'"
      end
    end

    def flagged? *search
      flags.any? do |flag|
        search.include? flag.name
      end
    end

    def flags
      @options.select {|o| o.type == :flag }
    end

    def settings
      @options.select {|o| o.type == :setting }
    end

    def setting name
      @options.find { |opt| opt.match name }
    end
  end
end
