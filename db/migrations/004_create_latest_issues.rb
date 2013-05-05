Sequel.migration do
  change do
    create_table :latest_issues do
      primary_key :id
      String      :login,     null: false, unique: false
      String      :title,     null: false, unique: true
      String      :html_url,  null: false, unique: true
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
