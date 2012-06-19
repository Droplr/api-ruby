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
          underscore_lookup       = Droplr::Configuration::CAMEL_TO_UNDERSCORE_FIELDS
          field                   = underscore_lookup[field] || field

          next if header.nil?

          # our header would have come back as a string, so we coerce its type
          hash[object_key][field.to_sym] = type_coerced_header(field, header)
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
      success_hash = {object_key => parsed_body}
      success_hash.merge({:request => {:status => response.status}})
    end

    def parse_error_headers(response)
      http_status = response.status
      message     = response.headers["x-droplr-errordetails"]
      error_code  = response.headers["x-droplr-errorcode"]
      raise DroplrError.new(message, error_code, http_status)
    end

  private

    def type_coerced_header(field, value)
      if Droplr::Configuration::INTEGER_FIELDS.include?(field)
        Integer(value)
      elsif Droplr::Configuration::BOOLEAN_FIELDS.include?(field)
        value == "true"
      else
        value
      end
    end

  end
end