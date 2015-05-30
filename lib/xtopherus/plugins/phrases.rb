module Xtopherus
  class Phrases
    include Cinch::Plugin

    set :react_on, :channel

    EXCEPTION_MSG = 'Oops, something went wrong...'

    match /alias (.+) => (.+)/, method: :store_alias, use_prefix: false
    def store_alias(m, from_key, to_key)
      store_phrase(m, from_key, "=", "${%s}" % to_key)
    end

    match /rem (.+) ([+-]?)= (.+)/, method: :store_phrase, use_prefix: false
    def store_phrase(m, key, op, value)
      lookup = key.downcase.strip
      phrase = Phrase.first(name: lookup, channel: m.channel.name)

      if phrase.nil? #< New phrase
        phrase = Phrase.new(
          name: lookup,
          channel: m.channel.name,
          version: 0,
          created_at: Time.now
        )
        phrase.save

        version = PhraseVersion.new(
          phrase_id: phrase.id,
          nick: m.user.nick,
          value: value,
          version: 0,
          created_at: Time.now
        )
        version.save
      else
        case op
        when '+'
          v = phrase.latest_version
          v.value = "%s %s" % [ v.value, value ]
          v.save
        when '-'
          v = phrase.latest_version
          v.value = v.value.sub(/#{value.strip}/, '').strip
          v.save
        else
          version = PhraseVersion.new(
            phrase_id: phrase.id,
            nick: m.user.nick,
            value: value,
            version: phrase.version + 1,
            created_at: Time.now
          )
          version.save

          # Increase version
          phrase.version = phrase.version + 1
          phrase.save
        end
      end

      m.reply('Thank you, sir.', true)
    rescue => e
      m.reply EXCEPTION_MSG
      m.reply e
      raise
    end

    match /([0-9]*)?\!give ([^ ]+) ([^ ]+)((?:\s(?:[^ ]*))*)/, method: :give_phrase, use_prefix: false
    def give_phrase(m, version, target, key, args)
      phrase, *args = phrase_args(key, m.channel.name, args)

      unless phrase.nil?
        # Get phrase
        if not version.empty? and phrase.has_version?(version.to_i)
          v = phrase.specific_version(version.to_i)
        else
          v = phrase.latest_version
        end

        m.reply "%s: %s" % [ target, replace_args(v.value, args) ]
      else
        m.reply "Did you mean: %s" % [ find_alike(key, m.channel.name, 5) ], true
      end
    rescue => e
      m.reply EXCEPTION_MSG, true
      m.reply e
      raise
    end

    match /([0-9]*)?\!msg ([^ ]+) ([^ ]+)((?:\s(?:[^ ]*))*)/, method: :msg_phrase, use_prefix: false
    def msg_phrase(m, version, target, key, args)
      phrase, *args = phrase_args(key, m.channel.name, args)

      unless phrase.nil?
        # Get phrase
        if !version.empty? and phrase.has_version?(version.to_i)
          v = phrase.specific_version(version.to_i)
        else
          v = phrase.latest_version
        end

        user = User(target)
        user.msg "%s" % replace_args(v.value, args)
      else
        m.reply("Did you mean: %s" % [ find_alike(key, m.channel.name, 5) ], true)
      end
    rescue => e
      m.reply EXCEPTION_MSG, true
      m.reply e
      raise
    end

    match /!find (.+)/, method: :find_phrase, use_prefix: false
    def find_phrase(m, key)
      likes = find_alike(key, m.channel.name)
      m.reply("Matches for %s: %s" % [ key, likes ], true) unless likes.empty?
    rescue => e
      m.reply EXCEPTION_MSG, true
      m.reply e
      raise
    end

    match /(\d+)?!forget (.+)/, method: :forget_phrase, use_prefix: false
    def forget_phrase(m, version, key)
      lookup = key.downcase.strip
      phrase = Phrase.first(:name => lookup, :channel => m.channel.name)

      unless phrase.nil?
        # Get phrase
        if !version.nil? and phrase.has_version?(version.to_i)
          v = phrase.specific_version(version.to_i)
        else
          v = phrase.latest_version
        end

        # Check owner
        if v.nick == m.user.nick
          v.delete

          # Delete version or whole phrase
          if 0 == phrase.version
            phrase.delete
          else
            phrase.version = phrase.version - 1
            phrase.save
          end

          m.reply("Thank you, sir.", true)
        else
          m.reply("Doesn't belong to you.", true)
        end
      else
        likes = find_alike(key, m.channel.name, 5)
        m.reply("Did you mean: %s" % [ likes  ], true) unless likes.empty?
      end
    rescue => e
      m.reply EXCEPTION_MSG, true
      m.reply e
      raise
    end

    match /([0-9]*)?(\!|\?)([^ ]+)((?:\s(?:[^ ]*))*)/, method: :get_phrase, use_prefix: false
    def get_phrase(m, version, op, key, args)
      # FIXME: Exclude keywords until groups are implemented
      return if [ "news", "best", "worst", "alias", "rem", "give", "find", "forget", "proto", "weather", "imdb" ].include?(key)

      phrase, *args = phrase_args(key, m.channel.name, args)

      # Channel aware
      if phrase.nil?
        phrase, *args = phrase_args(key, nil, args)
      end

      unless phrase.nil?
        # Get phrase version
        if !version.empty? and phrase.has_version?(version.to_i)
          v = phrase.specific_version(version.to_i)
        else
          v = phrase.latest_version
        end

        # Output based on op
        case op
        when "!"
          m.reply(replace_args(v.value, args))
        when "?"
          m.reply("'%s' is '%s' (Stored by %s on %s, r%d)" % [
              key, v.value, v.nick,
              v.created_at.strftime("%Y-%m-%d at %H:%M:%S"),
              v.version
            ], true)
        end
      else
        likes = find_alike(key, m.channel.name, 5)
        m.reply("Did you mean: %s" % [ likes ], true) unless likes.empty?
      end
    rescue => e
      m.reply EXCEPTION_MSG, true
      m.reply e
      raise
    end

    private

    def replace_args(value, args = [])
      required = 0

      value.gsub!(/(?:\${?([a-z0-9\*?]+)(-?)(?::([a-z]*))?}?)/) do |s|
        match, key, dash, meth = $~.to_a

        # Get index
        if 0 < args.size
          idx = key.to_i - 1 rescue 0

          # Join args or just select one
          if "-" == dash
            arg = args.slice(idx, args.size).join(" ")
          else
            arg = args[idx]
          end
        else
          # Not enough arguments
          arg = match
        end

        # Use string modifier
        case meth
        when 'upcase'     then arg.upcase
        when 'downcase'   then arg.downcase
        when 'reverse'    then arg.reverse
        when 'capitalize' then arg.capitalize
        when 'rand'       then phrase_rand(key)
        else
          # Find aliases
          if meth.nil? and not key.match(/\d/)
            phrase, *newargs = phrase_args(key, args)

            replace_args(phrase.latest_version.value, newargs) unless phrase.nil?
          else
            arg
          end
        end
      end

      value
    end

    def phrase_rand(key)
      pattern = key.gsub(/[\*\+? ]/, "*" => "%", "+" => "_", "?" => "_", " " => "")
      phrases = Phrase.where(Sequel.like(:name, "#{pattern}%")).all
      value   = ""

      # Get random phrase and exclude rand
      begin
        r = rand(phrases.size)

        value = phrases[r].latest_version.value
      end while value.include?(":rand}")

      value
    end

    def phrase_args(key, channel, args = [])
      lookup = key.downcase.strip
      arg    = ""

      # Split args
      args = args.split(" ") if args.is_a?(String)

      # Get phrase and check if args are part of it
      begin
        lookup << " #{arg}" unless arg.nil? or arg.empty?

        unless channel.nil?
          phrase = Phrase.first(name: lookup, channel: channel)
        else
          phrase = Phrase.first(name: lookup)
        end

        arg = args.shift if phrase.nil?
      end while phrase.nil? and arg.is_a?(String) and !arg.empty?

      [ phrase, *args ]
    end

    def find_alike(key, channel, limit = 10)
      result  = ""
      lookup  = key.downcase.strip

      phrases = Phrase.where(Sequel.like(:name, "#{lookup}%"),
        channel: channel).limit(limit).all

      unless phrases.nil?
        matches = []

        phrases.each do |p|
          matches << "%s[%d]" % [ p.name, p.version ]
        end

        result = matches.join(", ") unless(matches.empty?)
      end

      result
    end

  end
end
