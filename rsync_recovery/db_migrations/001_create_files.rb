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
      Integer :parent_id

      Datetime :created_at
      Datetime :modified_at
      Datetime :indexed_at

      index [:hostname, :path, :name, :sha], unique: true
    end
  end
end
