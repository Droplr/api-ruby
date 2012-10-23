require "base64"
require "faraday"
require "openssl"

require "droplr"

RSpec.configure do |config|
  # Allow passing :focus => true in a test or context to only run those tests
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end