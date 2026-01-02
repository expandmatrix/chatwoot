require 'net/http'
require 'openssl'

module EM
  class WebhookClient
    def initialize
      @base_url = ENV.fetch('EM_API_BASE_URL', 'http://api:3001')
      @secret = ENV.fetch('MESSAGING_WEBHOOK_SECRET', nil)
      @enabled = ENV.fetch('MESSAGING_WEBHOOK_ENABLED', 'true') == 'true'
    end

    def post_message_created(raw_json)
      return unless @enabled
      raise 'missing webhook secret' if @secret.nil? || @secret.empty?
      ts = Time.now.to_i.to_s
      sig = OpenSSL::HMAC.hexdigest('sha256', @secret, ts + raw_json)
      uri = URI.parse(@base_url + '/messaging/events/message-created')
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req['x-timestamp'] = ts
      req['x-signature'] = sig
      req.body = raw_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = 5
      http.open_timeout = 2
      http.start { |h| h.request(req) }
    end
  end
end
