module Xtopherus
  class Possess
    include Cinch::Plugin

    attr_accessor :available
    alias_method :available?, :available

    LIMIT = 60 * 5

    set react_on: :private

    match /possess\z/, method: :possess

    def possess(m)
      unless occupied?
        occupy_by(m)
        m.reply(
          "Oh, hello! I'm under your control for #{ LIMIT } seconds. " \
          "Now, write something! Prefix your sentence with an exclamation " \
          "mark."
        )
      end
    end

    match /.+/, method: :forward

    def forward(m)
      if occupied?
        if @possessor.prefix == m.prefix
          message = m.message.sub(/\A!(possess|revoke)\z/, '').sub(/\A!/, '')
          Channel(@bot.channels[0]).msg(message)
        else
          m.reply("I'm sorry, but someone has already possessed me. Be patient.")
        end
      end
    end

    match /revoke\z/, method: :revoke

    def revoke(m)
      if m && @possessor && m.prefix == @possessor.prefix
        @possessor = @occupied = nil
        m.reply(
          "What happened? I was unconcious! You used me like a tool! " \
          "I'm not your marionette. Farewell!"
        )
        timers.each(&:stop)
        timers.clear
      end
    end

    private

    def occupied?
      @occupied
    end

    def occupy_by(m)
      @possessor = m
      @occupied = true
      Timer(LIMIT) { force_revoke }
    end

    def force_revoke
      revoke(@possessor)
    end

  end
end
