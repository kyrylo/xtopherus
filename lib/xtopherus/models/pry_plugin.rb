module Xtopherus
  class PryPlugin < Sequel::Model(:pry_plugins)
    one_to_many :pry_plugin_download_stamps

    plugin :timestamps, update_on_create: true
  end
end
