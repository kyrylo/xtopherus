require 'sequel'
require 'sequel/extensions/migration'

module Xtopherus
  if ENV['DATABASE_URL']
    Database = Sequel.connect(ENV['DATABASE_URL'])
  else
    raise ArgumentError,
      "Set up credentials in DATABASE_ADDRESS environment variable. " \
      " Example: postgres://user:password@localhost/blog"
  end


  class << Database

    def migrate(to = nil, from = nil)
      migrations = File.join(File.expand_path('db'), 'migrations')
      if to == 0 && from == 0
        Sequel::Migrator.apply(self, migrations)
      else
        Sequel::Migrator.apply(self, migrations, to, from)
      end
    end

    def rollback
      current_version = self[:schema_info].first[:version]
      migrate(current_version.pred)
    end

  end
end
