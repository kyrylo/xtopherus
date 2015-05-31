# -*- coding: utf-8 -*-
require 'json'
require 'net/http'
class Xtopherus::Eval
  HOST    = 'eval.in'
  PORT    = 443
  HEADERS = {'Content-Type' => 'application/x-www-form-urlencoded'}
  FIELDS  = {'execute' => 'on', 'private' => 'on', 'lang' => 'ruby/mri-2.2'}
  WRAPPED = "p begin\n%s\nrescue Exception\n$!.class\nend"
  NEWLINE = "\n"
  include Cinch::Plugin
  set :prefix, /^>>/
  match /(.+)\z/, method: :eval

  def eval(m, rubycode)
    http = new_http
    payload = URI.encode_www_form FIELDS.merge(code: WRAPPED % rubycode)
    uri = http.post('/', payload, HEADERS)['Location']
    res = http.get uri + '.json'
    m.reply build_reply(res, uri)
  rescue Exception => e
    m.reply "I Dunno LOL ¯\(°_o)/¯ (psst, I do know: #{e})"
  end

  private
  def build_reply(res, uri)
    body = JSON.parse(res.body)['output']
    reply = ''
    body.each_char { |c| c == NEWLINE ? break : reply << c }
    "=> #{reply[0..79]} ... #{uri}"
  end

  def new_http
    Net::HTTP.new(HOST, PORT).tap do |http|
      http.use_ssl = true
      http.ssl_version = :TLSv1
    end
  end
end
