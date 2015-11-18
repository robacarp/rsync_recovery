require 'minitest/autorun'
require_relative '../rsync_recovery.rb'

module Testing
  def connect_database
    RsyncRecovery::Database.in_memory
  end

  def open_file relative_path
  end

  def assert_raises_message msg, &block
    except = assert_raises do
      yield
    end

    assert_match msg, except.message
  end
end
