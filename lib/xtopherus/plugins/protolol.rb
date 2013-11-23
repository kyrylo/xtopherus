require 'cgi'
require 'mechanize'

module Xtopherus
  class Protolol
    include Cinch::Plugin

    set :react_on, :channel

    match /protolol\z/

    def execute(m)
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      agent.max_history = 0

      page = agent.get('http://attrition.org/misc/ee/protolol.txt')
      protolol = page.body.split("\n")[0..-3].sample
      m.reply(CGI.unescapeHTML(protolol))
    end

  end
end
