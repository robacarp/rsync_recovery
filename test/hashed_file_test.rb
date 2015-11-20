require 'testing'

class HashedFileTest < Minitest::Test
  include Testing

  def setup
    connect_database
  end

  def test_properly_reads_file_attributes
    file = RsyncRecovery::HashedFile.from_path 'test/resources/one/one'
    assert file.kind_of?(RsyncRecovery::HashedFile)
    assert file.type == 'file'
  end
end
