module Droplr
  class AuthService < Service

    include Droplr::Authentication

    def get_user_tokens(auth_token)
      url = "#{Droplr::Configuration::AUTH_ENDPOINT}/#{auth_token}"
      execute_auth_request(:get, url, nil, base_headers)
    end

  # Anonymous authenticaton methods
  private

    def base_auth_request
      @base_auth_request ||= Faraday.new(:url => configuration.auth_url)
    end

    def execute_auth_request(method, url, body, headers)
      headers["Authorization"] ||= anonymous_authentication_header(authentication_params(method, url, headers))
      begin
        base_auth_request.run_request(method, url, body, headers)
      rescue Faraday::Error::ClientError
        message = "Could not connect to the API server. The server might be down, or you might have no internet connection."
        raise Droplr::UserError.new(message)
      end
    end

    def anonymous_authentication_header(options)
      prepared_options = {:method       => options[:method],
                          :path         => options[:path],
                          :date         => options[:date] || (Time.now.to_i * 1000).to_s,
                          :content_type => options[:content_type],
                          :request_type => "droplranon"}

      authentication_header(prepared_options)
    end

  end
end
