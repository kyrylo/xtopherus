Sequel.migration do
  change do
    create_table :download_stamps do
      primary_key :id
      Fixnum      :number, null: false, unique: false
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
