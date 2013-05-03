module Xtopherus
  class PryPlugin < Sequel::Model(:pry_plugins)
    plugin :timestamps, update_on_create: true
  end
end
