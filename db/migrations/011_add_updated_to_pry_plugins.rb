Sequel.migration do
  change do
    add_column :pry_plugins, :updated, DateTime
    from(:pry_plugins).update(updated: Time.now)
  end
end
