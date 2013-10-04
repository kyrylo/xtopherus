Sequel.migration do
  change do
    create_table :phrases do
      primary_key :id
      String      :name, unique: true
      String      :channel
      Fixnum      :version, default: 0
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
