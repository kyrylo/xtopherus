require 'net/https'
require 'json'

module Xtopherus
  class PryPluginsInfo
    include Cinch::Plugin

    set react_on: :channel

    match /latestplugin\z/,
          method: :report_latest_plugin

    match /plugin (.+)\z/,
          method: :report_plugin

    # 12 hours.
    timer 43200, method: :send_plugins_notification

    listen_to :join

    def listen(m)
      send_plugins_notification if m.user.nick == bot.nick
    end

    def report_plugin(m, plugin_name)
      plugin = PryPlugin.find(name: plugin_name.strip)
      if plugin
        m.reply "#{ plugin.authors } wrote #{ plugin.name } (kisses!). " \
                "#{ plugin.info }\. #{ plugin.homepage_uri }"
      else
        m.reply "There is no such plugin \"#{ plugin_name.strip }\". Example " \
                "of a valid request: `!plugin pry-developer_tools`"
      end
    end

    def report_latest_plugin(m)
      plugin = PryPlugin.order(:updated_at).last
      m.reply "#{ plugin.name } by #{ plugin.authors }. I'd send a patch, but " \
              "my hands doesn't work on it yet. #{ plugin.homepage_uri }"
    end

    def send_plugins_notification
      plugins = Gems.search('pry-')
      plugins.each { |info|
        params = {
          name:    info['name'],
          version: info['version'],
          authors: info['authors'],
          info:    info['info'],
          homepage_uri: info['homepage_uri'],
        }
        plugin = PryPlugin.find(name: params[:name])
        if plugin
          if plugin.version != params[:version]
            plugin.update(params)
            plugin.save
            bot.channels.each { |chan|
              Channel(chan).send(
                "Incredible #{ plugin.authors } updated #{ plugin.name } " \
                "to version #{ plugin.version }. Hup-hup! " \
                "#{ plugin.homepage_uri }") }
          end
        else
          plugin = PryPlugin.create(params)
          bot.channels.each { |chan|
            Channel(chan).send(
              "New Pry plugin, chaps! #{ plugin.name } was created by " \
              "#{ plugin.authors }. They revealed to me some secrets. " \
              "They said: \"#{ plugin.info }\". I heard Matz is already " \
              "using it! #{ plugin.homepage_uri }") }
        end
      }
    end

  end
end
