require 'testing'

class HashedFileTest < Minitest::Test
  include Testing

  def test_properly_reads_file_attributes
    debugger
    file = RsyncRecovery::HashedFile.from_path 'resources/one/one'
    debugger
  end
end
