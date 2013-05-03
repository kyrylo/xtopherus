Sequel.migration do
  change do
    create_table :pry_plugins do
      primary_key :id
      String      :name,         null: false, unique: true
      String      :version,      null: false, unique: false
      String      :authors,      null: false, unique: false
      String      :info,         null: true,  unique: false
      String      :homepage_uri, null: true,  unique: false
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
