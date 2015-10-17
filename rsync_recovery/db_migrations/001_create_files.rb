Sequel.migration do
  change do
    create_table? :hashed_files do
      primary_key :id
      String :hostname
      String :path
      String :name
      String :sha
      Integer :size

      index [:hostname, :path, :name, :sha], unique: true
    end
  end
end
