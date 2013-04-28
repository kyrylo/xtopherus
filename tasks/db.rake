namespace :db do

  desc 'Run migrations'
  task :migrate => :environment do
    Xtopherus::Database.migrate(ENV['TO'].to_i, ENV['FROM'].to_i)
  end

  desc 'Rollback database to the previous version'
  task :rollback => :environment do
    Xtopherus::Database.rollback
  end

end
