module Droplr
  class Service < Client

    class << self
      include Droplr::Authentication

      # make the configuration available to our included module
      def configuration
        @@configuration
      end

      def read_account_details
        base_request.get do |req|
          req.url Droplr::Configuration::ACCOUNT_ENDPOINT
          set_base_headers(req)
        end
      end

      def edit_account_details(account_options, request_options)
        base_request.put do |req|
          req.url Droplr::Configuration::ACCOUNT_ENDPOINT
          set_base_headers(req, request_options)
          req.headers["Content-Type"] = ""
          set_custom_request_headers(req, account_options, Droplr::Configuration::EDIT_ACCOUNT_FIELDS)
        end
      end

      def read_drop(code)
        base_request.get do |req|
          req.url "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"
          set_base_headers(req)
          req.headers["Content-Type"] = ""
        end
      end

      def list_drops(drop_options)
        base_request.get do |req|
          req.url build_query_strings_for_options("#{Droplr::Configuration::DROPS_ENDPOINT}.json",
                                                  drop_options,
                                                  Droplr::Configuration::LIST_DROPS_PARAMS)
          set_base_headers(req, {:content_type => "application/json"})
          set_json_request_headers(req)
        end
      end

      def shorten_link(link)
        base_request.post do |req|
          req.url Droplr::Configuration::LINKS_ENDPOINT
          set_base_headers(req, {:content_type => "text/plain"})
          req.headers["Content-Type"] = "text/plain"
          req.body                    = link
        end
      end

      def create_note(contents, drop_options)
        content_type = drop_options[:variant] ? "text/#{drop_options[:variant]}" : "text/plain"
        base_request.post do |req|
          req.url Droplr::Configuration::NOTES_ENDPOINT
          set_base_headers(req, {:content_type => content_type})
          req.headers["Content-Type"] = content_type
          req.body                    = contents
        end
      end

      def upload_file(contents, drop_options)
        # TODO : should i set a default filename or content_type? should i catch errors is if they aren't set?
        base_request.post do |req|
          req.url Droplr::Configuration::FILES_ENDPOINT
          set_base_headers(req, drop_options)
          req.headers["x-droplr-filename"] = drop_options[:filename]
          req.headers["Content-Type"]      = drop_options[:content_type]
          req.body                         = contents
        end
      end

      def delete_drop(code)
        base_request.delete do |req|
          req.url "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"
          set_base_headers(req)
          req.headers["Content-Type"] = ""
        end
      end

    private

      def set_base_headers(request, options = nil)
        # date header must be set first so our auth_header method can introspect
        # the request in order to find the date it should sign itself with
        request.headers["Date"]          = (Time.now.to_i * 1000).to_s
        request.headers["Authorization"] = auth_header(request, options)
        request.headers["User-Agent"]    = configuration.user_agent
      end

      def set_custom_request_headers(request, options = {}, allowed_fields = nil)
        # TODO : should i marshall this data to allow for options to be passed in as
        # "string" => "string" instead of :sym => "string"
        filtered_fields = options.reject { |option| allowed_fields.include?(option.to_s) }
        filtered_fields.each do |key, value|
          request.headers["x-droplr-#{key}"] = value
        end
      end

      def set_json_request_headers(request)
        request.headers["Content-Type"] = "application/json"
      end

      def build_query_strings_for_options(url, options, allowed_fields)
        # reject any options that don't exist in our allowed fields
        filtered_options = options.reject { |option| !allowed_fields.include?(option.to_s) }
        return url if options.empty?

        query_strings = filtered_options.map do |key, value|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end

        "#{url}?#{query_strings.join('&')}"
      end

      def base_request
        @base_request ||= Faraday.new({:url => configuration.base_url})
      end

    end
  end
end