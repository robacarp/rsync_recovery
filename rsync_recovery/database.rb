require 'sqlite3'
require 'sequel'


module RsyncRecovery
  class Database
    attr_reader :db

    class << self
      def connect(sqlite_url:)
        @connection ||= new sqlite_url
        load_models
        @connection
      end

      def load_models
        require_relative 'rsync_recovery/hashed_file'
        require_relative 'rsync_recovery/edge'
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
