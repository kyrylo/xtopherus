require 'net/https'
require 'json'

module Xtopherus
  class DownloadsInfo
    include Cinch::Plugin

    set react_on: :channel

    match /downloads\z/,
          method: :report_downloads

    timer 1_800, method: :send_downloads_notification

    def send_downloads_notification
      downloads = total_downloads
      @prev_downloads ||= (DownloadStamp.last || DownloadStamp.create(number: downloads))
      since_then = downloads - @prev_downloads.number

      if since_then >= rand(45_000..55_000)
        stamp = DownloadStamp.create(number: downloads)
        @prev_downloads = stamp
        days = (stamp.created_at - @prev_downloads.created_at).to_i / 86400
        bot.channels.each do |chan|
          downloads = number_with_delimiter(downloads)
          Channel(chan).send "Pry was downloaded #{ downloads } times. " \
                             "We've gotten #{ since_then } downloads in " \
                             "#{ days } days, which is kinda k00, I'd say."
        end
      end
    end

    def report_downloads(m)
      downloads = number_with_delimiter(DownloadStamp.last.number)
      m.reply "Pry was downloaded about #{ downloads } times."
    end

    def total_downloads
      uri = URI.parse('https://rubygems.org/api/v1/downloads/pry-0.9.12.json')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      json = JSON.parse(http.get(uri.request_uri).body)
      json['total_downloads']
    end

    def number_with_delimiter(number)
      parts = number.to_s.to_str.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      parts.join(',')
    end

  end
end
