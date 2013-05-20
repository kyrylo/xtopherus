Sequel.migration do
  change do
    create_table :pry_plugin_download_stamps do
      primary_key :id
      foreign_key :pry_plugin_id, :pry_plugins
      Fixnum      :number, default: 0
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
