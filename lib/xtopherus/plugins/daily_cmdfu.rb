module Xtopherus
  class DailyCmdfu
    include Cinch::Plugin

    set react_on: :channel

    timer 86400, method: :report_cmdfu

    listen_to :join

    def listen(m)
      report_cmdfu if m.user.nick == bot.nick
    end

    def report_cmdfu
      cmdfu = get_random_cmdfu_from_the_first_page
      random_cmdfu_from_random_page = true
      while Cmdfu.find(cmdfu_id: cmdfu['id'])
        cmdfu = if random_cmdfu_from_random_page = !random_cmdfu_from_random_page
                  get_random_cmdfu_from_random_page
                else
                  get_random_cmdfu_from_the_first_page
                end
      end

      Cmdfu.create(cmdfu_id: cmdfu['id'])

      bot.channels.each do |chan|
        Channel(chan).send "commandline-fu! #{ cmdfu['summary'] }: " \
                           "`#{ cmdfu['command'] }` ~ " \
                           "#{ shorten_link(cmdfu['url']) }"
      end
    end

    def get_random_cmdfu_from_the_first_page
      HTTParty.get('http://www.commandlinefu.com/commands/browse/json').sample
    end

    def get_random_cmdfu_from_random_page
      uri = "http://commandlinefu.com/commands/browse/sort-by-votes/" \
            "#{ rand(90001) }/json"
      HTTParty.get(uri).sample
    end

    def shorten_link(link)
      HTTParty.get("http://is.gd/create.php?format=simple&url=#{ link }")
    end
  end
end
