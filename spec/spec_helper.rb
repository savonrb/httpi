require "bundler"
Bundler.require :development

require "httpi"

require "support/some"
require "support/fixture"
require "support/matchers"

RSpec.configure do |config|
  config.include WebMock::API
  config.include HTTPI::SpecSupport
  config.mock_with :mocha
end
