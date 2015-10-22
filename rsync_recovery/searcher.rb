require 'digest'

module RsyncRecovery
  class Searcher
    attr_reader :hostname, :files
    IGNORE_FILES = ['.','..']

    def hostname
      @hostname ||= `hostname`.strip
    end

    def search(directory: '.')
      @files = []
      list(dir: directory)
    end

    def list(dir:, parent: nil)
      hashed = HashedFile.from_path dir, hostname: hostname, parent: parent
      @files << hashed

      return unless hashed.type == 'directory'

      Dir.entries(dir).each do |e| 
        next if IGNORE_FILES.include? e
        full_path = File.join dir, e
        list(dir: full_path, parent: hashed)
      end
    end
  end
end
