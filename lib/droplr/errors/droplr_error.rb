module Droplr
  class DroplrError < StandardError
    attr_reader :message, :error_code, :http_status, :json_body, :additional_info

    def initialize(message = nil, error_code = nil, http_status = nil, additional_info = nil)
      @message         = message
      @error_code      = error_code
      @http_status     = http_status
      @json_body       = build_json_body
      @additional_info = additional_info
    end

    def to_s
      base_string = ""
      base_string << "#{@http_status} - " if @http_status
      base_string << "#{@error_code} - "  if @error_code
      base_string << "#{@message}"        if @message
    end

  private

    def build_json_body
      return nil if @message.nil? && @error_code.nil? && @http_status.nil?
      json_body                       = {:error => {}}
      json_body[:error][:message]     = @message if @message
      json_body[:error][:error_code]  = @error_code if @error_code
      json_body[:error][:http_status] = @http_status if @http_status
    end

  end
end