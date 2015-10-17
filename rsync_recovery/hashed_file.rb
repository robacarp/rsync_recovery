module RsyncRecovery
  class HashedFile < Sequel::Model
    class << self
      def from_sha sha
      end
    end

    def validate
      super
    end

    def hash!
      self.sha = Digest::SHA2.file(File.join path, name).hexdigest
    end

  end
end
