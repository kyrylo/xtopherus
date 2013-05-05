module Xtopherus
  class LatestIssue < Sequel::Model(:latest_issues)
    plugin :timestamps, update_on_create: true
  end
end
