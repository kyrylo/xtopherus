# -*- coding: utf-8 -*-
require 'json'
require 'net/http'
class Xtopherus::Eval
  HOST    = 'eval.in'
  PORT    = 443
  HEADERS = {'Content-Type' => 'application/x-www-form-urlencoded'}
  FIELDS  = {'execute' => 'on', 'private' => 'on', 'lang' => 'ruby/mri-2.2'}
  WRAPPED = "p begin\n%s\nrescue Exception\n$!.class\nend"
  include Cinch::Plugin
  match /e (.+)\z/, method: :eval

  def eval(m, rubycode)
    http = new_http
    payload = URI.encode_www_form FIELDS.merge(code: WRAPPED % rubycode)
    res = http.post '/', payload, HEADERS
    res = http.get URI.parse(res['Location']).path + '.json'
    m.reply "=> #{JSON.parse(res.body)['output']}"
  rescue Exception => e
    m.reply "I Dunno LOL ¯\(°_o)/¯ (psst, I do know: #{e})"
  end

  private
  def new_http
    Net::HTTP.new(HOST, PORT).tap do |http|
      http.use_ssl = true
      http.ssl_version = :TLSv1
    end
  end
end
