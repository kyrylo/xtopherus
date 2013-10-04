require 'cgi'
require 'mechanize'

module Xtopherus
  class Commits
    include Cinch::Plugin

    set :react_on, :channel

    match /commit\z/

    def execute(m)
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      agent.max_history = 0

      page = agent.get('http://whatthecommit.com')
      commit = page.parser.xpath('//div /p').first.inner_html.chop
      m.reply(CGI.unescapeHTML(commit))
    end

  end
end
