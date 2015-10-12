require 'sqlite3'

module RsyncRecovery
  class Database
    attr_reader :db, :filename

    class << self
      def instance filename: nil
        @connection ||= new filename: filename
      end

      def query *params
        instance.query *params
      end
    end

    def initialize(filename: 'test.db')
      @filename = filename
      @db = SQLite3::Database.new filename
      schema_load
    end

    def query sql, *params
      @db.execute sql, *params
    end

    def hashy_query cols, sql, *params
      query(sql, *params).map do |row|
        h = {}
        cols.each_with_index do |field, i|
          h[field] = row[i]
        end

        h
      end
    end

    def schema_load
      statements = <<-SQL.split(';').map(&:strip).select {|s| s.length > 0}
        CREATE TABLE IF NOT EXISTS files (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hostname VARCHAR(32),
          path VARCHAR(255),
          name VARCHAR(64),
          sha VARCHAR(64)
        );

        -- don't reindex the same file on the same machine / path / sha
        CREATE INDEX IF NOT EXISTS unique_file_idx ON files (hostname, path, name, sha);
      SQL

      statements.each { |s| query s }
    end

    def inspect
      "<SQLite3 #{@filename}>"
    end
  end
end
