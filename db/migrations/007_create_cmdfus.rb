Sequel.migration do
  change do
    create_table :cmdfus do
      primary_key :id
      Fixnum      :cmdfu_id, null: false
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
