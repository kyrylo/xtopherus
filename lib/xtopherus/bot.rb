require 'yaml'
require 'ostruct'
module Xtopherus
  class Bot < Cinch::Bot
    class BotConfig
      def initialize(options)
        @conf = OpenStruct.new(options)
        @conf['plugins'].map! { |plugin| Object.const_get(plugin) }
      end

      def get; @conf end
    end

    def initialize(options)
      super()
      config = Bot::BotConfig.new(options)
      configure do |c|
        c.nick     = config.get.nick
        c.realname = config.get.realname
        c.user     = config.get.user
        c.server   = config.get.server
        c.port     = config.get.port
        c.channels = config.get.channels
        c.plugins.plugins = config.get.plugins
      end
    end
  end
end
