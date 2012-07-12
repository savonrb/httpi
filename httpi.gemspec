lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "httpi/version"

Gem::Specification.new do |s|
  s.name        = "httpi"
  s.version     = HTTPI::VERSION
  s.authors     = ["Daniel Harrington", "Martin Tepper"]
  s.email       = "me@rubiii.com"
  s.homepage    = "http://github.com/rubiii/#{s.name}"
  s.summary     = "Interface for Ruby HTTP libraries"
  s.description = "HTTPI provides a common interface for Ruby HTTP libraries."

  s.rubyforge_project = s.name

  s.add_dependency "rack"

  s.add_development_dependency "rake",    "~> 0.8.7"
  s.add_development_dependency "rspec",   "~> 2.7"
  s.add_development_dependency "mocha",   "~> 0.9.9"
  s.add_development_dependency "webmock", "~> 1.4.0"

  s.add_development_dependency "autotest"
  s.add_development_dependency "ZenTest", "4.5.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
