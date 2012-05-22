module Droplr
  module Parser
    extend self

    def parse_success_headers(headers, allowed_fields = nil)

      if allowed_fields
        allowed_fields.each_with_object({}) do |field, hash|
          header      = headers["x-droplr-#{field}"]
          next if header.nil?
          hash[field] = header
        end
      else
        {
          :success => true
        }
      end
    end

    def parse_error_headers(headers)
      {
        :errorcode    => headers["x-droplr-errorcode"],
        :errordetails => headers["x-droplr-errordetails"]
      }
    end

  end
end