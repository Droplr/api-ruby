require "droplr/version"
require "droplr/authentication"
require "droplr/configuration"
require "droplr/client"
require "droplr/service"
require "droplr/parser"

require "json"
require "base64"
require "openssl"
require "faraday"
require "uri"

module Droplr
  class DroplrError < StandardError; end
  class DroplrConfigurationError < StandardError; end
  class DroplrRequestError < StandardError; end
end