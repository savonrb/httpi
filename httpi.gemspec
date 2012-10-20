lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "httpi/version"

Gem::Specification.new do |s|
  s.name        = "httpi"
  s.version     = HTTPI::VERSION
  s.authors     = ["Daniel Harrington", "Martin Tepper"]
  s.email       = "me@rubiii.com"
  s.homepage    = "http://github.com/savonrb/#{s.name}"
  s.summary     = "Common interface for Ruby's HTTP libraries"
  s.description = "HTTPI provides a common interface for Ruby's HTTP libraries"

  s.rubyforge_project = s.name

  s.add_dependency "rack"

  s.add_development_dependency "rake",    "~> 0.9"
  s.add_development_dependency "rspec",   "~> 2.11"
  s.add_development_dependency "mocha",   "~> 0.12"
  s.add_development_dependency "webmock", "~> 1.8"
  s.add_development_dependency "webrick", "~> 1.3"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
