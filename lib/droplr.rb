require "droplr/version"
require "droplr/authentication"
require "droplr/configuration"
require "droplr/client"
require "droplr/service"
require "droplr/parser"

# error handling
require "droplr/errors/droplr_error"
require "droplr/errors/request_error"
require "droplr/errors/configuration_error"

# external utilities
require "json"
require "base64"
require "openssl"
require "faraday"
require "uri"