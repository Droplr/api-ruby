module Droplr
  class AuthClient

    attr_accessor :service

    def initialize(options, service = nil)
      check_client_configuration(options)
      configuration = Droplr::Configuration.new(options)
      self.service  = service || Droplr::AuthService.new(configuration)
    end

    def get_user_tokens(auth_token)
      response = service.get_user_tokens(auth_token)
      logger.debug "REsponse: #{response.body} #{response.status}"
      handle_json_response(response, :account)
    end
    
    #Helper methods for clients
    
    def auth_login_url(callback_url, session_id=false)
      url = "#{self.service.configuration.auth_url}login?callback=#{callback_url}"
      url = "#{url}&session=#{session_id}" if session_id != false
      url
    end
    
    def auth_register_url(callback_url, session_id=false)
      url = "#{self.service.configuration.auth_url}register?callback=#{callback_url}"
      url = "#{url}&session=#{session_id}" if session_id != false
      url
    end
    
    def self.was_successful(response)
      status = response.is_a?(Faraday::Response) ? response.status : response[:request][:status]
      status >= 200 && status < 400
    end

  private

    def handle_json_response(response, object_type, options = {})
      logger.debug "Response: #{response}"
      if Droplr::Client.was_successful(response)
        Droplr::Parser.parse_success_json(response, object_type, options)
      else
        Droplr::Parser.parse_auth_error_headers(response)
      end
    end

    def check_client_configuration(options)
      required_options = [:token, :secret, :app_public_key, :app_private_key, :user_agent]

      required_options.each do |required_option|
        unless options.include?(required_option)
          message = "Missing required field for an API connection: #{required_option}"
          raise Droplr::ConfigurationError.new(message)
        end
      end

      if options[:secret].length != 40
        message = "Secret should be a hexidecimal SHA1 digest, and thus 40 characters."
        raise Droplr::ConfigurationError.new(message)
      end
    end
  end
end