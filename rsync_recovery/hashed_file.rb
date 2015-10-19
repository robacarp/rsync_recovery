module RsyncRecovery
  class HashedFile < Sequel::Model
    class << self
      def from_path path, hostname: nil
        path = File.absolute_path path

        file = new(
          hostname: hostname,
          type: File.ftype(path),
          path: File.dirname(path),
          name: File.basename(path)
        )

        if file.type == 'file'
          file.created_at = File.ctime(path)
          file.modified_at = File.mtime(path)
          file.size = File.size?(path)
        end

        file
      rescue Errno::ENOENT => e
        puts path
        raise e
      end
    end

    def validate
      super
    end

    def hash!
      return unless type == 'file'
      self.sha = Digest::SHA2.file(File.join path, name).hexdigest
    end

    def inspect
      sha = @values[:sha] ? @values[:sha][0..8] : 'nil'
      name = @values[:name] || 'nil'
      "<HashedFile sha:#{sha} name:#{name}>"
    end
  end
end
