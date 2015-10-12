module RsyncRecovery
  class HashedFile
    class << self
      def from_sha sha
        Database.query('SELECT id, hostname, path, name, sha FROM files WHERE sha = ?', sha)
                .map do |row|
                  new(
                    id: row[0],
                    hostname: row[1],
                    path: row[2],
                    name: row[3],
                    sha: row[4]
                  )
                end
      end
    end

    attr_accessor :id, :name, :path, :sha, :hostname

    def initialize **params
      params.each do |name, value|
        method = "#{name}="
        if respond_to? method
          send method, value
        else
          puts "can't set #{name}"
        end
      end
    end


    def uniq?
      fail 'Cannot check for uniqueness without a sha' unless sha
      Database.query('SELECT * FROM files WHERE sha = ?', sha).empty?
    end

    def save
      puts "stashing #{name}"
      Database.query(<<-SQL, hostname, path, name, sha)
        INSERT INTO files (hostname, path, name, sha) VALUES (?, ?, ?, ?)
      SQL
    end

    def inspect
      "<HashedFile #{name.length == 0 ? '<nameless>' : name}>"
    end
  end
end
