module Droplr
  module Authentication

    def auth_header(req, options = nil)
      # use scrict_encode64 because we don't want line feeds added every 60 chars
      access_key = Base64.strict_encode64("#{configuration.app_public_key}:#{configuration.token}")
      signature  = auth_signature(req, options)

      "droplr #{access_key}:#{signature}"
    end

    def auth_signature(req, options = nil)
      key_and_secret = "#{configuration.app_private_key}:#{configuration.secret}"
      string_to_sign = "#{req.method.to_s.upcase} #{req.path} HTTP/1.1\n#{options[:content_type] if options}\n#{req.headers['Date']}"
      hmac_result    = OpenSSL::HMAC.new(key_and_secret, 'sha1').update(string_to_sign).digest

      Base64.strict_encode64(hmac_result)
    end

  end
end