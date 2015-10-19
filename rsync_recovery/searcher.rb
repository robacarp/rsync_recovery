require 'digest'

module RsyncRecovery
  class Searcher
    attr_reader :hostname, :files

    def hostname
      @hostname ||= `hostname`.strip
    end

    def search(directory: '.')
      @files = Dir[File.join directory, '**/*'].map do |path|
        HashedFile.from_path path, hostname: hostname
      end

      @files.compact!
    end
  end
end
