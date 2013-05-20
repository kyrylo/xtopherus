module Xtopherus
  class TopPryPlugin < Sequel::Model(:top_pry_plugins)
    many_to_one :pry_plugin

    plugin :timestamps, update_on_create: true
  end
end
