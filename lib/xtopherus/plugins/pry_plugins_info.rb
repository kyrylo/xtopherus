module Xtopherus
  class PryPluginsInfo
    include Cinch::Plugin
    include ChatHelper

    set react_on: :channel

    match /latestplugin\z/,
          method: :report_latest_plugin

    match /plugin (.+)\z/,
          method: :report_plugin

    match /freshplugin\z/,
          method: :report_fresh_plugin

    match /topplugin\z/,
          method: :report_topplugin

    # 12 hours.
    timer 43200, method: :send_plugins_notification

    # 1 week.
    timer 604800, method: :send_plugin_of_the_week_notification

    listen_to :join

    def listen(m)
      if m.user.nick == bot.nick
        send_plugins_notification
        send_plugin_of_the_week_notification(first_run: true)
      end
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

    def report_fresh_plugin(m)
      plugin = PryPlugin.order(:created_at).last
      m.reply "The youngest of them is #{ plugin.name } made by marvelous " \
              "#{ plugin.authors }. #{ plugin.homepage_uri }"
    end

    def report_topplugin(m)
      plugin = TopPryPlugin.last
      if plugin
        m.reply "#{ plugin.pry_plugin.name } is the leader of this week " \
                "(#{ number_with_delimiter(plugin.week_number) } downloads). " \
                "gem install #{ plugin.pry_plugin.name } & $BROWSER " \
                "#{ plugin.pry_plugin.homepage_uri }"
      else
        m.reply "No top plugin yet. I'm collecting some data, so try to " \
                "wait a few days."
      end
    end

    def send_plugin_of_the_week_notification(opts = {first_run: false})
      PryPlugin.all.each { |plugin|
        downloads = Gems.total_downloads(plugin.name)[:total_downloads]
        stamp = PryPluginDownloadStamp.new(number: downloads)
        plugin.add_pry_plugin_download_stamp(stamp)
        plugin.save
      }

      diffs = []
      PryPlugin.all.map { |plugin|
        last_plugins = PryPluginDownloadStamp.order(:id).
          where(pry_plugin_id: plugin.id).last(2)
        diff = last_plugins.first.number - last_plugins.last.number
        diffs << [diff, plugin]
      }

      unless opts[:first_run]
        second, best = diffs.sort_by!(&:first).last(2)
        worst = diffs.first

        TopPryPlugin.create(pry_plugin_id: best[1].id, week_number: best[0])

        second[0] = number_with_delimiter(second[0])
        best[0]   = number_with_delimiter(best[0])
        worst[0]  = number_with_delimiter(worst[0])

        bot.channels.each do |chan|
          Channel(chan).send "Fresh news, everyone! The plugin of the week is " \
                             "#{ best[1].name } with #{ best[0] } downloads " \
                             "(good job, #{ best[1].authors }!). " \
                             "#{ best[1].homepage_uri }"
          Channel(chan).send "The contributors of #{ second[1].name } really " \
                             "tried hard this week, but only managed to take " \
                             "the second place with #{ second[0] } downloads. " \
                             "#{ second[1].homepage_uri }"
          Channel(chan).send "Finally, last but least is #{ worst[1].name }. It " \
                             "was downloaded only #{ worst[0] } times. " \
                             "#{ worst[1].authors }, you should try harder!"
        end
      end
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
            Channel(bot.channels.first).send(
              "Incredible #{ plugin.authors } updated #{ plugin.name } " \
              "to version #{ plugin.version }. Hup-hup! " \
              "#{ plugin.homepage_uri }")
          end
        else
          plugin = PryPlugin.create(params)
          Channel(bot.channels.first).send(
            "New Pry plugin, chaps! #{ plugin.name } was created by " \
            "#{ plugin.authors }. They revealed to me some secrets. " \
            "They said: \"#{ plugin.info }\". I heard Matz is already " \
            "using it! #{ plugin.homepage_uri }")
        end
      }
    end

  end
end
