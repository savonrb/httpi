require "bundler"
Bundler.setup(:default, :development)

require "httpi"

require "rspec"
require "mocha/api"
require "webmock"

RSpec.configure do |config|
  config.include WebMock::API
  config.mock_with :mocha
end

HTTPI.log = false

require "support/fixture"
require "support/matchers"
