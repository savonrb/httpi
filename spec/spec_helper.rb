require 'bundler'
Bundler.setup(:default, :development)

unless RUBY_PLATFORM =~ /java/
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'httpi'
require 'rspec'

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = 'random'
end

HTTPI.log = false

require 'support/fixture'
require 'support/matchers'
