module Droplr
  class Configuration

    attr_accessor :token, :secret, :use_production, :app_public_key, :app_private_key, :user_agent

    # fallback credentials
    ANONYMOUS_TOKEN                 = "anonymous@droplr.com"
    ANONYMOUS_SECRET                = OpenSSL::Digest::SHA1.hexdigest("anonymous")

    # basic client configuration
    DROPLR_PRODUCTION_SERVER_PORT   = 443
    DROPLR_DEV_SERVER_PORT          = 8069
    DROPLR_PRODUCTION_SERVER_HOST   = "api.droplr.com"
    DROPLR_DEV_SERVER_HOST          = "dev.droplr.com"

    # endpoints
    ACCOUNT_ENDPOINT                = "/account"
    DROPS_ENDPOINT                  = "/drops"
    LINKS_ENDPOINT                  = "/links"
    NOTES_ENDPOINT                  = "/notes"
    FILES_ENDPOINT                  = "/files"

    # allowed fields
    EDIT_ACCOUNT_FIELDS             = %w(password theme usedomain domain userootredirect rootredirect dropprivacy)
    READ_ACCOUNT_FIELDS             = %w(id createdat subscriptionend type extraspace usedspace email usedomain rootredirect userootredirect dropprivacy activedrops dropcount maxuploadsize totalspace)
    CREATE_DROP_FIELDS              = %w(code createdat type title size privacy password obscurecode shortlink usedspace totalspace)
    CREATE_DROP_WITH_VARIANT_FIELDS = CREATE_DROP_FIELDS << "variant"
    READ_DROP_FIELDS                = %w(code createdat type variant title views lastaccess size filecreatedat privacy password obscurecode shortlink)
    LIST_DROPS_PARAMS               = %w(offset amount type sortBy order since until)

    def initialize(options)
      # TODO : throw exceptions if required fields are not present
      options.each do |key, value|
        self.send "#{key}=", value
      end
    end

    def base_url
      protocol = use_production ? "https" : "http"
      port     = use_production ? DROPLR_PRODUCTION_SERVER_PORT : DROPLR_DEV_SERVER_PORT
      host     = use_production ? DROPLR_PRODUCTION_SERVER_HOST : DROPLR_DEV_SERVER_HOST

      "#{protocol}://#{host}:#{port}/"
    end

  end
end