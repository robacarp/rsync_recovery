module RsyncRecovery
  module CLI
    class Drop
      class << self
        def drop
          puts "Dropping database"
          Database.connection.drop
        end
      end
    end
  end
end
