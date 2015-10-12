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
  #{BINARY} --analyze                             Not implemented.
  #{BINARY} --merge <file1.db> <file2.db>         Not implemented.
  #{BINARY} --help, -h                            This, help.
  #{BINARY} --version, -v                         Version info.

Options:
  --recursive            Not implemented.
  --data-file=<file.db>  Point to a specific data store. Useful for running the
                         script on several machines. (default: #{BINARY}.db)

Rsync Recovery.
        USAGE
      end

      def flags
        guard
        @options.flags
      end

      def settings
        guard
        @options.settings
      end

      def references
        guard
        @options.references
      end

      def flagged? name
        guard
        @options.flagged? name
      end

      def guard
        if ! defined? @options
          raise RuntimeError, 'CLI Options not parsed yet'
        end
      end

      def parse
        return @options if @options

        @options = new
        @options.parse
        @options.freeze

        builtins
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

    attr_reader :flags, :settings, :references

    def initialize
      @flags = []
      @references = []
      @settings = {
        recursive: 'true',
        database: "#{BINARY}.db"
      }
    end

    def parse
      ARGV.each do |arg|
        if arg[0] == '-'
          if arg.index('=')
            parse_setter arg
          else
            parse_flag arg
          end
        else
          @references << arg
        end
      end
    end

    def freeze
      @flags.freeze
      @settings.freeze
      @references.freeze
    end

    def parse_setter arg
      key, value = arg.split('=', 2)
      key = key.gsub(/-/,' ').strip
      validate key
      @settings[key] = value
    end

    def parse_flag arg
      validate arg
      @flags << symbolize(arg)
    end

    def symbolize str
      str.gsub(/-/,' ').strip.gsub(/ /,'_').to_sym
    end

    def validate option
      @possibilities ||= self.class.usage.scan(/\W-{1,2}[a-z]+/).map(&:strip)

      if ! @possibilities.include? option
        fail "Invalid option '#{option}'"
      end
    end

    def flagged? *flags
      @flags.find do |flag|
        flags.include? flag
      end
    end
  end
end