require 'base'

module Testing
  class Options < Base
    USAGE = RsyncRecovery::CLI::Base::USAGE

    def setup
      @opts = RsyncRecovery::Options.new(usage: USAGE, defaults: [])
    end

    def test_can_pass_options
      @opts.parse "--search --drop --merge file.one file.two".split(/\s/)

      assert @opts.flagged? :search
      refute @opts.flagged? :analyze
      assert @opts.flagged? :drop
      assert @opts.flagged? :merge
    end

    def test_provides_help_when_asked
      except = assert_raises do
        @opts.parse ['-h']
        @opts.try_to_help
      end

      assert_equal USAGE, except.message

      @opts.reset

      except = assert_raises do
        @opts.parse ['-v']
        @opts.try_to_help
      end

      assert_equal "#{RsyncRecovery::BINARY} #{RsyncRecovery::VERSION}", except.message
    end
  end
end
