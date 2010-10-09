require "rspec"
require "mocha"
require "webmock/rspec"

RSpec.configure do |config|
  config.include WebMock
  config.mock_with :mocha
end

require "support/fixture"
require "support/matchers"
