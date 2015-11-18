require './rsync_recovery'
RsyncRecovery::Database.connect sqlite_url: 'sqlite://database.file'
RsyncRecovery::Database.connection.log_queries
RsyncRecovery::Database.connection.schema_load
