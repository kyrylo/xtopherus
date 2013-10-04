module Xtopherus
  class Phrase < Sequel::Model(:phrases)
    one_to_many :phrase_versions

    plugin :timestamps, update_on_create: true

    def latest_version
      PhraseVersion.first(phrase_id: self.id, version: self.version)
    end

    def has_version?(version)
      0 <= version && version <= self.version ? true : false
    end

    def specific_version(version)
      v = nil

      if(self.has_version?(version))
        v = PhraseVersion.first(:phrase_id => self.id, :version => version)
      end

      v
    end

  end
end
