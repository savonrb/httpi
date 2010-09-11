require "rspec"
require "mocha"

RSpec.configure do |config|
  config.mock_with :mocha
end

require "support/helper_methods"
require "support/matchers"
