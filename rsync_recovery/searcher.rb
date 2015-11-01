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

    def hash_files(force: false)
      @unhashed = @files.dup.shuffle
      last_length = nil
      dup_count = 0

      while @unhashed.any? do
        file = @unhashed.pop
        did_hash = false

        if force
          did_hash = file.hash!
          state = :hashed
        else
          did_hash = file.smart_hash
          if file.changed_columns.any?
            state = :hashed
          else
            state = :already_indexed
          end
        end

        if file.valid? && ( file.changed_columns.any? || file.new? )
          file.save
        end

        yield file, state if block_given?
      end

    end
  end
end
