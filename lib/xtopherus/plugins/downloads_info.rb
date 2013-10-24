module Xtopherus
  class DownloadsInfo
    include Cinch::Plugin
    include ChatHelper

    set react_on: :channel

    match /downloads\z/, method: :report_downloads

    # 3 days.
    timer 60 * 60 * 24 * 3, method: :send_downloads_notification

    def send_downloads_notification
      downloads = Gems.total_downloads('pry')[:total_downloads]
      @prev_downloads ||= (DownloadStamp.last || DownloadStamp.create(number: downloads))
      since_then = downloads - @prev_downloads.number

      stamp = DownloadStamp.create(number: downloads)
      days = ((stamp.created_at - @prev_downloads.created_at) / 86400).ceil
      downloads = number_with_delimiter(downloads)
      Channel(bot.channels.first).send(
        "Pry was downloaded #{ numbers_with_delimiter(since_then) } times in " \
        "#{ days } and #{ downloads } times in total.")
      @prev_downloads = stamp
    end

    def report_downloads(m)
      downloads = Gems.total_downloads('pry')
      total_downloads = number_with_delimiter(downloads[:total_downloads])
      version_downloads = number_with_delimiter(downloads[:version_downloads])
      m.reply(
        "Pry was downloaded about #{ total_downloads } times " \
        "(#{ version_downloads } for the current version).")
    end

  end
end
