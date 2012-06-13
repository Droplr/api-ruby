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

      def edit_account_details(account_options)
        base_request.put do |req|
          req.url Droplr::Configuration::ACCOUNT_ENDPOINT
          req.headers["Content-Type"] = ""

          set_base_headers(req)
          account_options.each { |key, value| req.headers["x-droplr-#{key}"] = value }
        end
      end

      def read_drop(code)
        base_request.get do |req|
          req.url "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"
          req.headers["Content-Type"] = ""

          set_base_headers(req)
        end
      end

      def list_drops(drop_options)
        base_request.get do |req|
          req.url build_query_strings_for_options("#{Droplr::Configuration::DROPS_ENDPOINT}.json", drop_options)
          req.headers["Content-Type"] = "application/json"

          set_base_headers(req, {:content_type => "application/json"})
        end
      end

      def shorten_link(link)
        base_request.post do |req|
          req.url Droplr::Configuration::LINKS_ENDPOINT
          req.headers["Content-Type"] = "text/plain"

          set_base_headers(req, {:content_type => "text/plain"})
          req.body                    = link
        end
      end

      def create_note(contents, drop_options)
        content_type = drop_options[:variant] ? "text/#{drop_options[:variant]}" : "text/plain"
        base_request.post do |req|
          req.url Droplr::Configuration::NOTES_ENDPOINT
          req.headers["Content-Type"] = content_type

          set_base_headers(req, {:content_type => content_type})
          req.body                    = contents
        end
      end

      def upload_file(contents, drop_options)
        base_request.post do |req|
          req.url Droplr::Configuration::FILES_ENDPOINT
          req.headers["Content-Type"]      = drop_options[:content_type]

          set_base_headers(req, drop_options)
          req.headers["x-droplr-filename"] = drop_options[:filename]
          req.body                         = contents
        end
      end

      def delete_drop(code)
        base_request.delete do |req|
          req.url "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"
          req.headers["Content-Type"] = ""

          set_base_headers(req)
        end
      end

      def base_request
        @base_request ||= Faraday.new({:url => configuration.base_url})
      end

    private

      def set_base_headers(request, options = nil)
        # date header must be set first so our auth_header method can introspect
        # the request in order to find the date it should sign itself with
        request.headers["Date"]          = (Time.now.to_i * 1000).to_s
        request.headers["User-Agent"]    = configuration.user_agent

        auth_options                     = auth_options_from_request(request, options)
        request.headers["Authorization"] = auth_header(auth_options)
      end

      def auth_options_from_request(request, options)
        {
          :method       => request.method.to_s,
          :path         => request.path,
          :date         => request.headers["Date"],
          :content_type => options ? options[:content_type] : nil
        }
      end

      def build_query_strings_for_options(url, options = nil)
        return url unless options && options.any?
        query_strings = options.map do |key, value|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end

        "#{url}?#{query_strings.join('&')}"
      end

    end
  end
end