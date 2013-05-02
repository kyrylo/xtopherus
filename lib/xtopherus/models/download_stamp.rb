module Xtopherus
  class DownloadStamp < Sequel::Model(:download_stamps)
    plugin :timestamps, update_on_create: true
  end
end
