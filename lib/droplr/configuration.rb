module Droplr
  class Configuration

    attr_accessor :token, :secret, :use_production, :app_public_key, :app_private_key, :user_agent

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

    # allowed values
    EDIT_ACCOUNT_FIELDS             = %w(password theme usedomain domain userootredirect rootredirect dropprivacy)
    READ_ACCOUNT_FIELDS             = %w(id createdat type subscriptionend maxuploadsize extraspace usedspace totalspace email usedomain domain userootredirect rootredirect dropprivacy theme dropcount)
    CREATE_DROP_FIELDS              = %w(code createdat type title size privacy password obscurecode shortlink usedspace totalspace)
    CREATE_DROP_WITH_VARIANT_FIELDS = CREATE_DROP_FIELDS << "variant"
    READ_DROP_FIELDS                = %w(code createdat type title size privacy password obscurecode shortlink variant views lastaccess)
    LIST_DROPS_PARAMS               = %w(offset amount type sortBy order since until)
    NOTE_VARIANTS                   = %w(markdown textile code plain)

    # some converting to stay inline with ruby conventions
    UNDERSCORED_FIELDS              = {
      "createdat"       => "created_at",
      "customerid"      => "customer_id",
      "dropcount"       => "drop_count",
      "dropprivacy"     => "drop_privacy",
      "extraspace"      => "extra_space",
      "lastaccess"      => "last_access",
      "maxuploadsize"   => "max_upload_size",
      "obscurecode"     => "obscure_code",
      "rootredirect"    => "root_redirect",
      "shortlink"       => "short_link",
      "subscriptionend" => "subscription_end",
      "totalspace"      => "total_space",
      "usedomain"       => "use_domain",
      "usedspace"       => "used_space",
      "userootredirect" => "use_root_redirect",
    }

    def initialize(options)
      options.each do |key, value|
        self.send "#{key}=", value
      end
    end

    # implement our own attr_accessor_with_default setup here so we can fall back
    # to anonymous credentials
    def use_production
      @use_production ||= @use_production.nil? ? true : @use_production
    end

    def use_production=(value)
      @use_production = value
    end

    def base_url
      protocol = use_production ? "https" : "http"
      port     = use_production ? DROPLR_PRODUCTION_SERVER_PORT : DROPLR_DEV_SERVER_PORT
      host     = use_production ? DROPLR_PRODUCTION_SERVER_HOST : DROPLR_DEV_SERVER_HOST

      "#{protocol}://#{host}:#{port}/"
    end

  end
end