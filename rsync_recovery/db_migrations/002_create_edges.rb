Sequel.migration do
  change do
    create_table? :edges do
      foreign_key :parent_id, :hashed_files
      foreign_key :child_id, :hashed_files

      primary_key [:parent_id, :child_id]
      index [:parent_id, :child_id], unique: true
    end
  end
end
