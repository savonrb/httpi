require "bundler"
Bundler.require :default, :development

RSpec.configure do |config|
  config.include WebMock::API
  config.mock_with :mocha
end

HTTPI.log = false  # disable for specs

require "support/fixture"
require "support/matchers"
