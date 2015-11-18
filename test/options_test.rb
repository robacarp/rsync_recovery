require 'testing'

class Options < Minitest::Test
  include Testing

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
    assert_raises_message USAGE do
      @opts.parse ['-h']
      @opts.try_to_help
    end

    @opts.reset

    assert_raises_message "#{RsyncRecovery::BINARY} #{RsyncRecovery::VERSION}" do
      @opts.parse ['-v']
      @opts.try_to_help
    end
  end
end
