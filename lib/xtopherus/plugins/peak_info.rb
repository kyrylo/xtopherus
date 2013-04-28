module Xtopherus
  class PeakInfo
    include Cinch::Plugin

    set react_on: :channel

    listen_to :join

    match /peak\z/,
          method: :report_peak,
          use_suffix: false

    def self.find_peak
      Peak.order(:users_quantity).last
    end

    @@current_peak = proc { (p = find_peak) && p.users_quantity || 1 }.()

    def listen(m)
      return if m.user.nick == bot.nick
      user_count = m.channel.users.size
      if user_count > @@current_peak
        @@current_peak += 1
        Peak.create(users_quantity: @@current_peak, scorer_nick: m.user.nick)
        m.reply "[New peak: #{ @@current_peak }]"
      end
    end

    def report_peak(m)
      peak = self.class.find_peak
      m.reply "[Current peak: #{ peak.users_quantity }. " \
              "The scorer: #{ peak.scorer_nick }]"
    end

  end
end
