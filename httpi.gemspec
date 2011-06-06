lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "httpi/version"

Gem::Specification.new do |s|
  s.name        = "httpi"
  s.version     = HTTPI::VERSION
  s.authors     = ["Daniel Harrington", "Martin Tepper", "James Cook"]
  s.email       = "me@rubiii.com"
  s.homepage    = "http://github.com/rubiii/#{s.name}"
  s.summary     = "Common interface for Ruby HTTP clients"
  s.description = "HTTPI provides a common interface for Ruby HTTP clients."

  s.rubyforge_project = s.name

  s.add_dependency "rack"

  s.add_development_dependency "rspec",   "~> 2.5"
  s.add_development_dependency "webmock", "~> 1.4.0"
  s.add_development_dependency "autotest"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
