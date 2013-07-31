module Xtopherus
  class Help
    include Cinch::Plugin

    set react_on: :channel

    match /help\z/
    method: :display_help

    def display_help(m)
      m.reply 'https://github.com/kyrylo/xtopherus/wiki/Help'
    end

  end
end
