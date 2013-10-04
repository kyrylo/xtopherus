module Xtopherus
  class PhraseVersion < Sequel::Model(:phrase_versions)
    many_to_one :phrase

    plugin :timestamps, update_on_create: true
  end
end
