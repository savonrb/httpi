lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "httpi/version"

Gem::Specification.new do |s|
  s.name = "httpi"
  s.version = HTTPI::VERSION
  s.authors = "Daniel Harrington"
  s.email = "me@rubiii.com"
  s.homepage = "http://github.com/rubiii/#{s.name}"
  s.summary = "Common interface for Ruby HTTP libraries"
  s.description = "HTTPI provides a common interface for different HTTP libraries."

  s.rubyforge_project = s.name

  s.add_development_dependency "httpclient", "~> 2.1.5"
  s.add_development_dependency "curb", "~> 0.7.8"

  s.add_development_dependency "rspec", "2.0.0.beta.19"
  s.add_development_dependency "mocha", "~> 0.9.8"

  s.files = Dir["[A-Z]*", "{autotest,lib,spec}/**/*"] + %w(.rspec)
  s.require_path = "lib"
end
