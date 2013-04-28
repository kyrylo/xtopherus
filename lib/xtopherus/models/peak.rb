module Xtopherus
  class Peak < Sequel::Model(:peaks)
    plugin :timestamps, update_on_create: true
  end
end
