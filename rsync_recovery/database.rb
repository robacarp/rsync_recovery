require 'sqlite3'
require 'sequel'


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

      @db = Sequel.connect "sqlite://#{filename}"
      Sequel::Model.db = @db
      Sequel::Model.plugin :auto_validations
    end

    def drop
      @db.tables.each do |table|
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
      "<SQLite3 #{@filename}>"
    end
  end
end
