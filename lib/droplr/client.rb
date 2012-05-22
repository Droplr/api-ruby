module Droplr
  class Client

    @@configuration = nil

    # TODO : remove test credentials for easy copypasta before publishing
    # require 'json'; require 'base64'; require 'openssl'; require 'faraday'; require 'droplr';
    # d = Droplr::Client.new({:token => "user_1@droplr.com", :secret => Digest::SHA1.hexdigest("pass_1"), :use_production => false, :app_public_key => "app_0_publickey", :app_private_key => "app_0_privatekey", :user_agent => 'DroplrWeb/1.0.3'})
    # d.read_account_details

    def initialize(options)
      @@configuration = Configuration.new options
    end

    def read_account_details
      response = Droplr::Service.read_account_details

      handle_header_response(response, Droplr::Configuration::READ_ACCOUNT_FIELDS)
    end

    def edit_account_details(options)
      # TODO : throw an exception if they fail to provide any options here
      response = Droplr::Service.edit_account_details(options)

      handle_header_response(response, Droplr::Configuration::READ_ACCOUNT_FIELDS)
    end

    def list_drops(options = nil)
      # TODO : disregard invalid options sooner
      response = Droplr::Service.list_drops(options)

      handle_json_response(response)
    end

    def read_drop(code)
      response = Droplr::Service.read_drop(code)

      handle_header_response(response, Droplr::Configuration::READ_DROP_FIELDS)
    end

    def shorten_link(link)
      response = Droplr::Service.shorten_link(link)

      handle_header_response(response, Droplr::Configuration::CREATE_DROP_FIELDS)
    end

    def create_note(contents, options = {})
      response = Droplr::Service.create_note(contents, options)

      handle_header_response(response, Droplr::Configuration::CREATE_DROP_WITH_VARIANT_FIELDS)
    end

    def upload_file(contents, options = {})
      response = Droplr::Service.upload_file(contents, options)
      puts response.inspect
      handle_header_response(response, Droplr::Configuration::CREATE_DROP_WITH_VARIANT_FIELDS)
    end

    def delete_drop(code)
      response = Droplr::Service.delete_drop(code)
    end

  private

    def handle_header_response(response, allowed_headers)
      # TODO : handle 204s, etc.
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

  end
end