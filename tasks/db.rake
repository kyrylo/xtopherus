namespace :db do

  desc 'Create a new database'
  task :create do
    require 'sequel'
    Sequel.sqlite(File.join(File.expand_path('db'), 'my_brain.db'))
  end

  desc 'Run migrations'
  task :migrate => :environment do
    Xtopherus::Database.migrate(ENV['TO'].to_i, ENV['FROM'].to_i)
  end

  desc 'Rollback database to the previous version'
  task :rollback => :environment do
    Xtopherus::Database.rollback
  end

end
