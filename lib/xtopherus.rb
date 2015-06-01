require 'cinch'
require 'cinch-seen'

require 'gems'
require 'octokit'
require 'openssl'

require_relative 'xtopherus/bot'
require_relative 'xtopherus/database'
require_relative 'xtopherus/chat_helper'

require_relative 'xtopherus/models/peak'
require_relative 'xtopherus/models/download_stamp'
require_relative 'xtopherus/models/pry_plugin'
require_relative 'xtopherus/models/latest_issue'
require_relative 'xtopherus/models/pry_plugin_download_stamp'
require_relative 'xtopherus/models/top_pry_plugin'
require_relative 'xtopherus/models/phrase'
require_relative 'xtopherus/models/phrase_version'

require_relative 'xtopherus/plugins/peak_info'
require_relative 'xtopherus/plugins/downloads_info'
require_relative 'xtopherus/plugins/pry_plugins_info'
require_relative 'xtopherus/plugins/issues_notifier'
require_relative 'xtopherus/plugins/help'
require_relative 'xtopherus/plugins/commits'
require_relative 'xtopherus/plugins/classname'
require_relative 'xtopherus/plugins/phrases'
require_relative 'xtopherus/plugins/possess'
require_relative 'xtopherus/plugins/protolol'
require_relative 'xtopherus/plugins/tweeter'
require_relative 'xtopherus/plugins/eval'
require_relative 'xtopherus/plugins/memo'

module Xtopherus

  # The VERSION file must be in the root directory of the library.
  VERSION_FILE = File.expand_path('../../VERSION', __FILE__)

  VERSION = File.exist?(VERSION_FILE) ?
    File.read(VERSION_FILE).chomp : '(could not find VERSION file)'

  OpenSSL::SSL::VERIFY_PEER = 0

end
