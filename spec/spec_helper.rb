require 'bundler'
Bundler.setup(:default, :development)

unless RUBY_PLATFORM =~ /java/
  require 'simplecov'

  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'httpi'
require 'rspec'

# The em_http adapter needs eventmachine, which has no JRuby-compatible C
# extension and does not build on Ruby >= 4.1 (1.2.7, its last release, still
# uses the untyped Data API that Ruby removed). The Gemfile omits the gems
# there, so detect them instead of assuming they are installed.
EM_HTTP_AVAILABLE = RUBY_PLATFORM !~ /java/ && begin
  require "em-synchrony"
  require "em-http-request"
  true
rescue LoadError
  false
end

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = 'random'
end

HTTPI.log = false

require 'support/fixture'
require 'support/matchers'
