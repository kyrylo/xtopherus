module Xtopherus
  class PeakInfo
    include Cinch::Plugin

    set react_on: :channel

    listen_to :join

    match /peak\z/,
          method: :report_peak

    def self.find_peak
      Peak.order(:users_quantity).last
    end

    @@current_peak = proc { (p = find_peak) && p.users_quantity || 1 }.()

    def listen(m)
      user_count = m.channel.users.size
      if user_count > @@current_peak
        @@current_peak = user_count
        Peak.create(users_quantity: @@current_peak, scorer_nick: m.user.nick)
        m.reply "New peak: #{ @@current_peak }"
      end
    end

    def report_peak(m)
      peak = self.class.find_peak
      m.reply "Current peak: #{ peak.users_quantity }. " \
              "The scorer: #{ peak.scorer_nick }. " \
              "Registered on: #{ peak.updated_at.strftime("%Y-%m-%d") }."
    end

  end
end
