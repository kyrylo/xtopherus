module Xtopherus
  class Cmdfu < Sequel::Model(:cmdfus)
    plugin :timestamps, update_on_create: true
  end
end
