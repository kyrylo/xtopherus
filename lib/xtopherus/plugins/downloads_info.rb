module Xtopherus
  class DownloadsInfo
    include Cinch::Plugin

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
        bot.channels.each do |chan|
          downloads = number_with_delimiter(downloads)
          Channel(chan).send "Pry was downloaded #{ downloads } times. " \
                             "We've gotten #{ since_then } downloads in " \
                             "#{ days } days, which is kinda k00, I'd say."
        end
        @prev_downloads = stamp
      end
    end

    def report_downloads(m)
      downloads = number_with_delimiter(DownloadStamp.last.number)
      m.reply "Pry was downloaded about #{ downloads } times."
    end

    def number_with_delimiter(number)
      parts = number.to_s.to_str.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      parts.join(',')
    end

  end
end
