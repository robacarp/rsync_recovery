require 'digest'

module RsyncRecovery
  class Searcher
    attr_reader :hostname, :files

    def hostname
      @hostname ||= `hostname`.strip
    end

    def search(directory: '.')
      @files = Dir[File.join directory, '*'].map do |file|
        next if File.directory? file

        HashedFile.new(
          hostname: hostname,
          path: File.dirname( File.absolute_path(file) ),
          name: File.basename(file),
          sha: Digest::SHA2.file(file).hexdigest
        )
      end

      @files.compact!
    end
  end
end
