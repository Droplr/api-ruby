module Droplr
  module Authentication

    def authentication_header(options)
      # use scrict_encode64 because we don't want line feeds added every 60 chars
      access_key   = Base64.strict_encode64("#{configuration.app_public_key}:#{configuration.token}")
      signature    = authentication_signature(options)
      request_type = options[:request_type] || "droplr"

      "#{request_type} #{access_key}:#{signature}"
    end

    def authentication_signature(options)
      key_and_secret = "#{configuration.app_private_key}:#{configuration.secret}"
      string_to_sign = "#{options[:method].upcase} #{options[:path]} HTTP/1.1\n#{options[:content_type]}\n#{options[:date]}"
      hmac_result    = OpenSSL::HMAC.new(key_and_secret, "sha1").update(string_to_sign).digest

      Base64.strict_encode64(hmac_result)
    end

  end
end