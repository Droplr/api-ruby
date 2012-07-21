module Droplr
  class Service < Client

    class << self
      include Droplr::Authentication

      # make the configuration available to our included module
      def configuration
        @@configuration
      end

      def read_account_details
        url = Droplr::Configuration::ACCOUNT_ENDPOINT

        execute_request(:get, url, nil, base_headers)
      end

      def edit_account_details(account_options)
        url     = Droplr::Configuration::ACCOUNT_ENDPOINT
        headers = base_headers.merge("Content-Type" => "")

        account_options.each { |key, value| headers["x-droplr-#{key}"] = value.to_s }
        execute_request(:put, url, nil, headers)
      end

      def read_drop(code)
        url = "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"

        execute_request(:get, url, nil, base_headers)
      end

      def list_drops(drop_options)
        url     = build_query_strings_for_options("#{Droplr::Configuration::DROPS_ENDPOINT}.json", drop_options)
        headers = base_headers.merge("Content-Type" => "application/json")

        execute_request(:get, url, nil, headers)
      end

      def shorten_link(link)
        url     = Droplr::Configuration::LINKS_ENDPOINT
        headers = base_headers.merge("Content-Type" => "text/plain")

        execute_request(:post, url, link, headers)
      end

      def create_note(contents, drop_options)
        url          = Droplr::Configuration::NOTES_ENDPOINT
        content_type = drop_options[:variant] ? "text/#{drop_options[:variant]}" : "text/plain"
        headers      = base_headers.merge("Content-Type" => content_type)

        execute_request(:post, url, contents, headers)
      end

      def upload_file(contents, drop_options)
        url     = Droplr::Configuration::FILES_ENDPOINT
        headers = base_headers.merge("Content-Type"      => drop_options[:content_type],
                                     "x-droplr-filename" => drop_options[:filename])

        execute_request(:post, url, contents, headers)
      end

      def delete_drop(code)
        url = "#{Droplr::Configuration::DROPS_ENDPOINT}/#{code}"

        execute_request(:delete, url, nil, base_headers)
      end

      def base_request
        @base_request ||= Faraday.new(:url => configuration.base_url)
      end

    private

      def execute_request(method, url, body, headers)
        headers["Authorization"] ||= authentication_header(authentication_params(method, url, headers))

        begin
          base_request.run_request(method, url, body, headers)
        rescue Faraday::Error::ClientError
          message = "Could not connect to the API server. The server might be down, or you might have no internet connection."
          raise Droplr::UserError.new(message)
        end
      end

      def authentication_params(method, url, headers)
        {:method       => method.to_s,
         :path         => url.match(/[\w\/\.]*/)[0], # avoid matching the query params
         :date         => headers["Date"],
         :content_type => headers["Content-Type"] || ""}
      end

      def base_headers
        # date header must be set first so our authentication_header method can introspect
        # the request in order to find the date it should sign itself with
        {
          "Date"       => (Time.now.to_i * 1000).to_s,
          "User-Agent" => configuration.user_agent
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