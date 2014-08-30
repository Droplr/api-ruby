module Droplr
  class Client

    attr_accessor :service

    def initialize(options, service = nil)
      check_client_configuration(options)
      configuration = Droplr::Configuration.new(options)
      self.service  = service || Droplr::Service.new(configuration)
    end

    def read_account_details
      response = service.read_account_details

      handle_json_response(response, :account)
    end

    def edit_account_details(options = {})
      options = camelized_params(options)
      check_for_empty_params(options, "You must provide at least one account field to update.")

      options  = params_without_invalid_fields(options, Droplr::Configuration::EDIT_ACCOUNT_FIELDS)
      response = service.edit_account_details(options)

      handle_json_response(response, :account)
    end

    def list_drops(options = {})
      options  = params_without_invalid_fields(options, Droplr::Configuration::LIST_DROPS_PARAMS)
      response = service.list_drops(options)

      handle_json_response(response, :drops)
    end

    def read_drop(code = nil)
      check_for_empty_params(code, "You must specify the drop you wish to read.")

      response = service.read_drop(code)
      handle_json_response(response, :drop)
    end

    def shorten_link(link = nil)
      check_for_empty_params(link, "You must specify the link you wish to shorten.")
      check_for_valid_url(link)

      response = service.shorten_link(link)
      handle_json_response(response, :drop)
    end

    def create_note(contents = nil, options = {})
      # allow the user to pass in no second argument and default to plain. we might remove
      # the check of an invalid variant to allow the API to make this decision
      options = {:variant => "plain"}.merge(options)

      check_for_empty_params(contents, "You must specify the contents of a note to upload.")
      check_for_invalid_params([options[:variant]],
                               Droplr::Configuration::NOTE_VARIANTS,
                               "If a note variant is specified, it must be one of: #{Droplr::Configuration::NOTE_VARIANTS.join(', ').downcase}")

      response = service.create_note(contents, options)
      handle_json_response(response, :drop)
    end

    def upload_file(contents = nil, options = {})
      check_for_empty_params(contents,               "You must specify the contents of a file to upload.")
      check_for_empty_params(options[:filename],     "You must specify the filename of a file to upload.")
      check_for_empty_params(options[:content_type], "You must specify the content_type of a file to upload.")

      response = service.upload_file(contents, options)
      handle_json_response(response, :drop)
    end

    def delete_drop(code = nil)
      check_for_empty_params(code, "You must specify the drop you wish to delete.")

      response = service.delete_drop(code)
      self.class.was_successful(response)
    end

    def self.was_successful(response)
      status = response.is_a?(Faraday::Response) ? response.status : response[:request][:status]
      status >= 200 && status < 400
    end

  private

    def handle_json_response(response, object_type, options = {})
      if Droplr::Client.was_successful(response)
        Droplr::Parser.parse_success_json(response, object_type, options)
      else
        Droplr::Parser.parse_error_headers(response)
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

    def params_without_invalid_fields(params, allowed_params)
      coercion_hash = Droplr::Configuration::UNDERSCORE_TO_JSON_FIELDS

      allowed_params = params.select do |key, value|
        converted_key = coercion_hash[key.to_s] || key.to_s

        allowed_params.include?(converted_key)
      end

      allowed_params
    end

    def check_for_invalid_params(params, allowed_params, message = nil)
      coercion_hash = Droplr::Configuration::UNDERSCORE_TO_JSON_FIELDS

      params.each do |key, value|
        converted_key = coercion_hash[key.to_s] || key.to_s
        unless allowed_params.include?(converted_key)
          message = message || "Invalid parameter supplied for request: #{converted_key}"
          raise Droplr::UserError.new(message, nil, 400)
        end
      end
    end

    def check_for_empty_params(params, message = nil)
      if params.nil? || params.empty?
        message = message || "You must provide at least one option for this request."
        raise Droplr::UserError.new(message, nil, 400)
      end
    end

    def check_for_valid_url(url)
      if (url =~ URI::regexp).nil?
        message = "The link you're trying to shorten appears to be invalid."
        raise Droplr::UserError.new(message, nil, 400)
      end
    end

    def camelized_params(params)
      converted_params = {}
      coercion_hash    = Droplr::Configuration::UNDERSCORE_TO_JSON_FIELDS

      params.each do |key, value|
        new_key                   = coercion_hash[key.to_s] || key
        converted_params[new_key] = value
      end

      converted_params
    end

  end
end