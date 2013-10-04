require 'mechanize'

module Xtopherus
  class Classname
    include Cinch::Plugin

    set :react_on, :channel

    match /classname\z/

    def execute(m)
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      @agent.max_history = 0

      page = @agent.get('http://www.classnamer.com/')
      m.reply(page.search("//p[@id='classname']").text)
    end

  end
end
