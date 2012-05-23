module Droplr
  class Client

    @@configuration = nil

    # TODO : remove test credentials for easy copypasta before publishing
    # require 'json'; require 'base64'; require 'openssl'; require 'faraday'; require 'droplr';
    # d = Droplr::Client.new({:token => "user_1@droplr.com", :secret => Digest::SHA1.hexdigest("pass_1"), :use_production => false, :app_public_key => "app_0_publickey", :app_private_key => "app_0_privatekey", :user_agent => 'DroplrWeb/1.0.3'})
    # d.read_account_details

    def initialize(options)
      check_client_configuration(options)
      @@configuration = Configuration.new(options)
    end

    def read_account_details
      response = Droplr::Service.read_account_details
      handle_header_response(response, Droplr::Configuration::READ_ACCOUNT_FIELDS)
    end

    def edit_account_details(options = {})
      check_for_empty_params(options, "You must provide at least one account field to update.")
      check_for_invalid_params(options, Droplr::Configuration::EDIT_ACCOUNT_FIELDS)

      response = Droplr::Service.edit_account_details(options)
      handle_header_response(response, Droplr::Configuration::READ_ACCOUNT_FIELDS)
    end

    def list_drops(options = {})
      check_for_invalid_params(options, Droplr::Configuration::LIST_DROPS_PARAMS)

      response = Droplr::Service.list_drops(options)
      handle_json_response(response)
    end

    def read_drop(code = nil)
      check_for_empty_params(code, "You must specify the drop you wish to read.")

      response = Droplr::Service.read_drop(code)
      handle_header_response(response, Droplr::Configuration::READ_DROP_FIELDS)
    end

    def shorten_link(link = nil)
      check_for_empty_params(link, "You must specify the link you wish to shorten.")
      # TODO : not sure that this is the best method to do this check
      check_for_valid_url(link)

      response = Droplr::Service.shorten_link(link)
      handle_header_response(response, Droplr::Configuration::CREATE_DROP_FIELDS)
    end

    def create_note(contents = nil, options = {})
      # allow the user to pass in no second argument and default to plain. we might remove
      # the check of an invalid variant to allow the API to make this decision
      options = {:variant => "plain"}.merge(options)

      check_for_empty_params(contents, "You must specify the contents of a note to upload.")
      check_for_invalid_params([options[:variant]],
                               Droplr::Configuration::NOTE_VARIANTS,
                               "If a note variant is specified, it must be oen of: #{Droplr::Configuration::NOTE_VARIANTS.join(', ').downcase}")

      response = Droplr::Service.create_note(contents, options)
      handle_header_response(response, Droplr::Configuration::CREATE_DROP_WITH_VARIANT_FIELDS)
    end

    def upload_file(contents = nil, options = {})
      check_for_empty_params(contents,               "You must specify the contents of a file to upload.")
      check_for_empty_params(options[:filename],     "You must specify the filename of a file to upload.")
      check_for_empty_params(options[:content_type], "You must specify the content_type of a file to upload.")

      response = Droplr::Service.upload_file(contents, options)
      handle_header_response(response, Droplr::Configuration::CREATE_DROP_WITH_VARIANT_FIELDS)
    end

    def delete_drop(code = nil)
      check_for_empty_params(code, "You must specify the drop you wish to delete.")

      response = Droplr::Service.delete_drop(code)
      handle_header_response(response)
    end

  private

    def handle_header_response(response, allowed_headers = nil)
      if is_success(response)
        Droplr::Parser.parse_success_headers(response.headers, allowed_headers)
      else
        Droplr::Parser.parse_error_headers(response.headers)
      end
    end

    def handle_json_response(response)
      if is_success(response)
        JSON.parse(response.body)
      else
        Droplr::Parser.parse_error_headers(response.headers)
      end
    end

    def is_success(response)
      successful_responses = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
      successful_responses.include?(response.status)
    end

    def check_client_configuration(options)
      required_options = [:token, :secret, :app_public_key, :app_private_key, :user_agent]

      required_options.each do |required_option|
        unless options.include?(required_option)
          raise DroplrConfigurationError, "Missing required field for an API connection: #{required_option}"
        end
      end

      if options[:secret].length != 40
        raise DroplrConfigurationError, "Secret should be a hexidecimal SHA1 digest, and thus 40 characters."
      end
    end

    def check_for_invalid_params(params, allowed_params, message = nil)
      params.each do |key, value|
        unless allowed_params.include?(key.to_s)
          message = message || "Invalid parameter supplied for request: #{key}"
          raise DroplrRequestError, message
        end
      end
    end

    def check_for_empty_params(params, message = nil)
      if params.nil? || params.empty?
        message = message || "You must provide at least one option for this request."
        raise DroplrRequestError, message
      end
    end

    def check_for_valid_url(url)
      if (url =~ URI::regexp).nil?
        raise DroplrRequestError, "The link you're trying to shorten appears to be invalid."
      end
    end

  end
end