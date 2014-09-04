lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'httpi/version'

Gem::Specification.new do |s|
  s.name        = 'httpi'
  s.version     = HTTPI::VERSION
  s.authors     = ['Daniel Harrington', 'Martin Tepper']
  s.email       = 'me@rubiii.com'
  s.homepage    = "http://github.com/savonrb/#{s.name}"
  s.summary     = "Common interface for Ruby's HTTP libraries"
  s.description = s.summary

  s.rubyforge_project = s.name
  s.license = 'MIT'

  s.add_dependency 'rack'

  s.add_development_dependency 'rubyntlm', '~> 0.3.2'
  s.add_development_dependency 'rake',     '~> 10.0'
  s.add_development_dependency 'rspec',    '~> 2.14'
  s.add_development_dependency 'mocha',    '~> 0.13'
  s.add_development_dependency 'puma',     '~> 2.3.2'

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'
end
