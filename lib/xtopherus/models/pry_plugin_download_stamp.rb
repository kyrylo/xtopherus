module Xtopherus
  class PryPluginDownloadStamp < Sequel::Model(:pry_plugin_download_stamps)
    many_to_one :pry_plugin

    plugin :timestamps, update_on_create: true
  end
end
