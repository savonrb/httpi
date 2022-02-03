lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'httpi/version'

Gem::Specification.new do |s|
  s.name        = 'httpi'
  s.version     = HTTPI::VERSION
  s.authors     = ['Daniel Harrington', 'Martin Tepper']
  s.email       = 'me@rubiii.com'
  s.homepage    = "https://github.com/savonrb/httpi"
  s.summary     = "Common interface for Ruby's HTTP libraries"
  s.description = s.summary

  s.required_ruby_version = '>= 2.3'

  s.license = 'MIT'

  s.add_dependency 'rack'

  s.add_development_dependency 'rubyntlm', '~> 0.3.2'
  s.add_development_dependency 'rake',     '~> 13.0'
  s.add_development_dependency 'rspec',    '~> 3.5'
  s.add_development_dependency 'mocha',    '~> 0.13'
  s.add_development_dependency 'puma',     '~> 5.0'
  s.add_development_dependency 'webmock'

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
