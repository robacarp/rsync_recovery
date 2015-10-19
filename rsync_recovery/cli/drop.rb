module RsyncRecovery
  module CLI
    class Drop
      class << self
        def drop
          puts "Dropping database"
          Database.instance.drop
        end
      end
    end
  end
end
