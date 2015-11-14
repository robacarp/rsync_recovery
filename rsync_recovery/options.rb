module RsyncRecovery
  class Options
    # hacky docopty class because docopt wasn't working.
    # report bugs to /dev/null
    attr_reader :options

    def initialize(usage:, defaults:)
      @usage = usage
      @defaults = defaults.dup
      reset
    end

    def parse argv
      unparsed = argv.dup
      matched = []
      while unparsed.any?
        opt = unparsed.shift
        if opt[0] == '-'
          matched.push opt
        else
          ref = opt
          opt = matched.pop
          opt = Array(opt)
          opt.push ref
          matched.push opt
        end
      end

     matched.each do |opt|
        option = parse_arg *opt
        validate option
        @options.push option
      end
    end

    def reset
      @options = @defaults.map { |o| parse_arg o }
    end

    def parse_arg arg, *references
      opt = Option.parse(arg, references)
      opt
    end

    def validate option
      @possibilities ||= @usage.scan(/\W-{1,2}[a-z-]+/).map(&:strip)

      match = @possibilities.index {|name| option.match name}

      unless match
        fail "Invalid option '#{option.name}'"
      end
    end

    def try_to_help
      if flagged? :help, :h
        fail @usage
      end

      if flagged? :version, :v
        fail "#{BINARY} #{VERSION}"
      end
    end

    def enforce_one_of *params
      unless flagged? *params
        fail @usage
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
