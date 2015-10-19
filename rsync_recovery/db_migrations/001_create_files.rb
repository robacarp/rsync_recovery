Sequel.migration do
  change do
    create_table? :hashed_files do
      primary_key :id

      String :hostname
      String :type
      String :path
      String :name
      String :sha
      Integer :size

      Datetime :created_at
      Datetime :modified_at

      index [:hostname, :path, :name, :sha], unique: true
    end
  end
end
