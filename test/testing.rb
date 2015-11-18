require 'minitest/autorun'
require_relative '../rsync_recovery.rb'

module Testing
  def assert_raises_message msg, &block
    except = assert_raises do
      yield
    end

    assert_match msg, except.message
  end

  def connect_database
  end
end
