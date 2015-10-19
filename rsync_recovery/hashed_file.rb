module RsyncRecovery
  class HashedFile < Sequel::Model
    class << self
      def from_path path, hostname: nil
        path = File.absolute_path path
        type = File.ftype path
        name = File.basename path
        location = File.dirname path

        file = where(
          hostname: hostname,
          path: location,
          name: name
        ).first

        unless file
          file = new(
            hostname: hostname,
            type: type,
            path: location,
            name: name,
            # indexed_at: Time.now
          )
        end

        if file.type == 'file'
          file.created_at  = File.ctime(path)
          file.modified_at = File.mtime(path)
          file.size        = File.size?(path)
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

    def smart_hash
      return unless new? || changed_columns.any?
      hash!

      nil
    end

    def hash!
      return unless type == 'file'
      # return if sha && ! rehash

      self.sha = Digest::SHA2.file(File.join path, name).hexdigest
    end

    def inspect
      sha = @values[:sha] ? @values[:sha][0..8] : 'nil'
      "<HashedFile sha:#{sha} type:#{@values[:type] || 'nil'} name:#{@values[:name] || 'nil'}>"
    end
  end
end
