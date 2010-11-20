require "bundler"
Bundler.require :default, :development

RSpec.configure do |config|
  config.include WebMock::API
  config.mock_with :mocha
end

require "support/fixture"
require "support/matchers"
