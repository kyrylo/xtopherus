Sequel.migration do
  change do
    create_table :phrase_versions do
      primary_key :id
      foreign_key :phrase_id, :phrases
      String      :nick
      String      :value
      Fixnum      :version, default: 0
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
