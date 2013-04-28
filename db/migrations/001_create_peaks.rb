Sequel.migration do
  change do
    create_table :peaks do
      primary_key :id
      Fixnum      :users_quantity, null: false
      String      :scorer_nick,    unique: false, size: 15, null: false
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
