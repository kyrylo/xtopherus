module Xtopherus
  class DownloadsInfo
    include Cinch::Plugin
    include ChatHelper

    set react_on: :channel

    match /downloads\z/,
    method: :report_downloads

    # 30 minutes.
    timer 1_800, method: :send_downloads_notification

    def send_downloads_notification
      downloads = Gems.total_downloads('pry', '0.9.12')[:total_downloads]
      @prev_downloads ||= (DownloadStamp.last || DownloadStamp.create(number: downloads))
      since_then = downloads - @prev_downloads.number

      if since_then >= rand(45_000..55_000)
        stamp = DownloadStamp.create(number: downloads)
        days = ((stamp.created_at - @prev_downloads.created_at) / 86400).ceil
        downloads = number_with_delimiter(downloads)
        Channel(bot.channels.first).send(
          "Pry was downloaded #{ numbers_with_delimiter(since_then) } times in " \
          "#{ days } and #{ downloads } times in total.")
        @prev_downloads = stamp
      end
    end

    def report_downloads(m)
      downloads = number_with_delimiter(DownloadStamp.last.number)
      m.reply "Pry was downloaded about #{ downloads } times."
    end

  end
end
