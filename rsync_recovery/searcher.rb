require 'digest'

module RsyncRecovery
  class Searcher
    attr_reader :hostname, :files

    def hostname
      @hostname ||= `hostname`.strip
    end

    def search(directory: '.')
      @files = Dir[File.join directory, '**/*'].map do |file|
        type = File.ftype file
        next unless type == 'file'

        HashedFile.new(
          hostname: hostname,
          path: File.dirname( File.absolute_path(file) ),
          name: File.basename(file),
          size: File.size?(file)
        )
      end

      @files.compact!
    end
  end
end
