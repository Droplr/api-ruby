module Droplr
  module Parser
    extend self

    def parse_success_json(response, object_key, options = {})
      options      = options.reverse_merge(:flatten => true)
      parsed_body  = response.body ? JSON.parse(response.body) : nil
      success_hash = {}

      # if we do have a body, we should go through and build each member of the object
      # we want to return so we get consistent repsonses. sometimes this will be an array
      # for which we need to parse all elements, other times a single hash.
      if parsed_body && parsed_body.is_a?(Array)
        corrected_response = parsed_body.map do |response_element|
          json_case_correct_object(response_element, options[:flatten])
        end
      elsif parsed_body
        corrected_response = json_case_correct_object(parsed_body, options[:flatten])
      end

      success_hash[object_key] = corrected_response ||= nil
      success_hash.merge({:request => {:status => response.status}})
    end

    def parse_error_headers(response)
      http_status     = response.status
      message         = response.headers["x-droplr-errordetails"]
      error_code      = response.headers["x-droplr-errorcode"]
      additional_info = response.headers.each_with_object({}) do |header, hash|
        next unless header_name = header[0][/(?<=x-droplr-)[\w]+/]
        next if ["errordetails", "errorcode"].include?(header_name)
        hash[header_name] = header[1]
      end

      # raise an error that clients will be able to capture
      raise Droplr::UserError.new(message, error_code, http_status, additional_info)
    end
    
    def parse_auth_error_headers(response)
      parsed_body     = response.body ? JSON.parse(response.body) : nil
      http_status     = response.status
      message         = "AuthError: #{parsed_body['name']}"
      error_code      = parsed_body["statusCode"]

      # raise an error that clients will be able to capture
      raise Droplr::UserError.new(message, error_code, http_status)
    end


  private

    def json_case_correct_object(element, flatten)
      corrected_hash = {}

      if flatten
        element = flatten_nested_values(element)
      end

      element.each do |key, value|
        key = Droplr::Configuration::JSON_TO_UNDERSCORE_FIELDS[key] || key
        corrected_hash[key.to_sym] = value
      end
      corrected_hash
    end

    def flatten_nested_values(hash, base_object = {})
      hash.each_with_object(base_object) do |(key, value), memo|
        if value.is_a?(Hash)
          memo.merge! flatten_nested_values(value, memo)
        else
          memo[key] = value
        end
      end
    end

  end
end