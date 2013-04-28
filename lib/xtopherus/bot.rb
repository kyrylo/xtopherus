require 'ostruct'
require 'yaml'

module Xtopherus

  class Bot < Cinch::Bot
    class BotConfig
      def initialize
        default_conf = begin
          YAML.load_file(File.expand_path('~/.xtopherus'))
        rescue Errno::ENOENT
          {}
        end

        @conf = OpenStruct.new({
          nick:     'Xtopherus',
          realname: 'Xtopherus',
          user:     'Xtopherus',
          server:   'irc.freenode.net',
          port:     6667,
          channels: ['#xtopherus-test']
        }.merge!(default_conf))
      end

      def get; @conf end
    end

    def initialize
      super

      config = Bot::BotConfig.new

      configure do |c|
        c.nick     = config.get.nick
        c.realname = config.get.realname
        c.user     = config.get.user
        c.server   = config.get.server
        c.port     = config.get.port
        c.channels = config.get.channels
        c.plugins.plugins = [ ]
      end
    end
  end

end
