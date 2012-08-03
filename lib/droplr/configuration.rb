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

    # fields that need conversion in our parser when passed as a string
    INTEGER_FIELDS = {
      "account"  => %w(subscription_end max_upload_size extra_space used_space total_space drop_count created_at),
      "drop"     => %w(id created_at),
      "customer" => %w()
    }
    BOOLEAN_FIELDS = {
      "account"  => %w(use_domain use_root_redirect),
      "drop"     => %w(owner_is_pro),
      "customer" => %w()
    }
    ENCODED_FIELDS = {
      "account"  => %w(),
      "drop"     => %w(title),
      "customer" => %w()
    }

    # header-formatted fields come back as downcased strings, but we want underscored.
    HEADER_TO_UNDERSCORE_FIELDS     = {
      "createdat"       => "created_at",
      "customerid"      => "customer_id",
      "dropcount"       => "drop_count",
      "dropprivacy"     => "drop_privacy",
      "extraspace"      => "extra_space",
      "filecreatedat"   => "file_created_at",
      "lastaccess"      => "last_access",
      "maxuploadsize"   => "max_upload_size",
      "obscurecode"     => "obscure_code",
      "ownerispro"      => "owner_is_pro",
      "previewthumb"    => "preview_thumb",
      "previewsmall"    => "preview_small",
      "previewmedium"   => "preview_medium",
      "referreremail"   => "referrer_email",
      "rootredirect"    => "root_redirect",
      "subscriptionend" => "subscription_end",
      "totalspace"      => "total_space",
      "usedomain"       => "use_domain",
      "usedspace"       => "used_space",
      "userootredirect" => "use_root_redirect"
    }

    UNDERSCORE_TO_HEADER_FIELDS     = HEADER_TO_UNDERSCORE_FIELDS.invert

    # json-formatted fields come back as camel-cased, but we want underscored.
    JSON_TO_UNDERSCORE_FIELDS       = {
      "sortBy"        => "sort_by",
      "obscureCode"   => "obscure_code",
      "createdAt"     => "created_at",
      "fileCreatedAt" => "file_created_at",
      "lastAccess"    => "last_access",
      "previewThumb"  => "preview_thumb",
      "previewSmall"  => "preview_small",
      "previewMedium" => "preview_medium"
    }

    UNDERSCORE_TO_JSON_FIELDS        = JSON_TO_UNDERSCORE_FIELDS.invert

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