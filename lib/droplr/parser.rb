module Droplr
  module Parser
    extend self

    def parse_success_headers(response, object_key, allowed_fields = nil)
      # we explicitly set our allowed fields to ensure we're not returning objects with
      # a bunch of fields that aren't useful to the user
      if allowed_fields
        headers   = response.headers
        base_hash = {object_key => {}}

        success_hash = allowed_fields.each_with_object(base_hash) do |field, hash|
          header                  = headers["x-droplr-#{field}"]
          # make sure to return our fields as properly underscored instead of camel-cased
          underscore_lookup       = Droplr::Configuration::HEADER_TO_UNDERSCORE_FIELDS
          field                   = underscore_lookup[field] || field

          next if header.nil?

          # our header would have come back as a string, so we coerce its type
          hash[object_key][field.to_sym] = type_coerced_header(object_key.to_s, field, header)
        end

        # and we add our own content field, so it is always available. this can't come back in
        # the headers because in the case of a note or a binary or something, it could be huge.
        if object_key == :drop
          response_content = response.status == 307 ? headers["Location"] : response.body
          success_hash[object_key][:content] = response_content
        end

        # we name this in conjunction with faraday's conventions so we can check for an error
        # in the original response or our bulit object in the same way
        success_hash.merge({:request => {:status => response.status}})
      else
        {:request => {:status => response.status}}
      end
    end

    def parse_success_json(response, object_key)
      parsed_body  = response.body ? JSON.parse(response.body) : nil
      success_hash = {}

      # if we do have a body, we should go through and build each member of the object
      # we want to return so we get consistent repsonses. sometimes this will be an array
      # for which we need to parse all elements, other times a single hash.
      if parsed_body && parsed_body.is_a?(Array)
        corrected_response = parsed_body.map do |response_element|
          json_case_correct_object(response_element)
        end
      elsif parsed_body
        corrected_response = json_case_correct_object(parsed_body)
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

  private

    def json_case_correct_object(element)
      corrected_hash = {}
      element.each do |key, value|
        key = Droplr::Configuration::JSON_TO_UNDERSCORE_FIELDS[key] || key
        corrected_hash[key.to_sym] = value
      end
      corrected_hash
    end

    def type_coerced_header(object_key, field, value)
      if Droplr::Configuration::INTEGER_FIELDS[object_key].include?(field)
        Integer(value)
      elsif Droplr::Configuration::BOOLEAN_FIELDS[object_key].include?(field)
        value == "true"
      elsif Droplr::Configuration::ENCODED_FIELDS[object_key].include?(field)
        Base64.strict_decode64(value)
      else
        value
      end
    end

  end
end