require "rspec"
require "mocha"

RSpec.configure do |config|
  config.mock_with :mocha
end

require "support/fixture"
require "support/matchers"
