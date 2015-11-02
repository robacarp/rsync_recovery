module RsyncRecovery
  class HashedFile < Sequel::Model
    class << self
      def from_path path, hostname: nil, parent: nil
        path = File.absolute_path path
        type = File.ftype path
        name = File.basename path
        location = File.dirname path

        new_file = false

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

          new_file = true
        end

        if file.type == 'file'
          file.created_at  = File.ctime(path)
          file.modified_at = File.mtime(path)
          file.size        = File.size?(path)
        end

        file.save

        if parent && new_file
          Edge.create parent: parent, child: file
        end

        file
      rescue Errno::ENOENT => e
        puts path
        raise e
      end
    end

    one_to_many :descendants, key: :parent_id, class: 'RsyncRecovery::Edge'
    one_to_many :ancestors,  key: :child_id,  class: 'RsyncRecovery::Edge'

    def children
      descendants.map(&:child)
    end

    def parents
      ancestors.map(&:parent)
    end

    def validate
      super
    end

    def smart_hash
      return true unless sha.nil? || new? || changed_columns.any?
      hash!
    end

    def hash!
      if type == 'file'
        hash_file
      else
        hash_folder
      end
    end

    def hash_file
      self.sha = Digest::SHA2.file(File.join path, name).hexdigest
      true
    end

    def hash_folder
      return false unless children.all? { |file| file.reload; file.sha }
      data = children.map(&:sha).join("\n")
      self.sha = Digest::SHA2.hexdigest(data)
      true
    end

    def inspect
      sha = @values[:sha] ? @values[:sha][0..8] : 'nil'
      "<HashedFile sha:#{sha} type:#{@values[:type] || 'nil'} name:#{@values[:name] || 'nil'}>"
    end
  end
end
