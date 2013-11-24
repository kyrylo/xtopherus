require 'twitter'

module Xtopherus
  class Tweeter
    include Cinch::Plugin

    set :react_on, :channel

    match /tw (.+)\z/

    CLIENT = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    def execute(m, seek)
      tweets = CLIENT.search(seek + ' -rt', result_type: 'recent', count: 3)
      tweets.each do |tweet|
        m.reply("@#{ tweet.user.handle }: #{ tweet.text }")
      end
    end

  end
end
