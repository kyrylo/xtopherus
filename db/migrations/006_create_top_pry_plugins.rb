Sequel.migration do
  change do
    create_table :top_pry_plugins do
      primary_key :id
      foreign_key :pry_plugin_id, :pry_plugins
      Fixnum      :week_number, default: 0
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
