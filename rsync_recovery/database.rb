require 'sqlite3'
require 'sequel'
require 'logger'

module RsyncRecovery
  class Database
    attr_reader :db

    class << self
      def connect(sqlite_url:)
        return @connection if @connection
        @connection = new url: sqlite_url
        @connection.schema_load
        load_models

        @connection
      end

      def in_memory
        connect sqlite_url: 'sqlite:/'
      end

      def load_models
        require_relative 'hashed_file'
        require_relative 'edge'
      end

      def reconnect_models
        HashedFile.set_dataset :hashed_files
        Edge.set_dataset :edges
      end

      def connection
        fail 'No database connection established' unless @connection
        @connection
      end

      def query *params
        instance.query *params
      end
    end

    def initialize(url: 'test.db')
      @url = url

      @db = Sequel.connect @url
      Sequel::Model.db = @db
      Sequel::Model.plugin :auto_validations
    end

    def log_queries
      @db.loggers << Logger.new(STDOUT)
    end

    def drop
      # HACK HACK HACK :|
      @db.tables.sort.each do |table|
        @db.drop_table table
      end
    end

    def query sql, *params
      @db.execute sql, *params
    end

    def schema_load
      Sequel.extension :migration
      Sequel::Migrator.run @db, File.join($root, 'rsync_recovery/db_migrations')
    end

    def inspect
      "<SQLite3 #{@url}>"
    end
  end
end
