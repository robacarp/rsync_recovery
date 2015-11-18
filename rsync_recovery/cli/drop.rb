module RsyncRecovery
  module CLI
    class Drop
      class << self
        def drop
          puts "Dropping database"
          Database.connection.tap do |db|
            db.drop
            db.schema_load
          end
          Database.reconnect_models
        end
      end
    end
  end
end
