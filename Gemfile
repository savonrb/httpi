source 'https://rubygems.org'
gemspec

gem 'jruby-openssl',                                       :platforms => :jruby

gem 'public_suffix', '~> 4.0'

# http clients
gem 'httpclient',          '~> 2.3',    :require => false
gem 'curb',                '~> 0.8',    :require => false, :platforms => [:ruby]
gem 'em-http-request',                  :require => false, :platforms => [:ruby]
gem 'em-synchrony',                     :require => false, :platforms => [:ruby, :jruby]
# excon >= 1.5.0 fixes CVE-2026-54171 but requires Ruby >= 3.1.
# On Ruby 3.0 fall back to the old line. The audit job runs on 3.4,
# so it resolves the patched excon.
gem 'excon', (RUBY_VERSION >= '3.1' ? '>= 1.5.0' : '~> 0.71'), :require => false, :platforms => [:ruby, :jruby]
gem 'net-http-persistent', '~> 4.0',    :require => false
gem 'http',                             :require => false

# adapter extensions
gem 'rack'
gem 'socksify'

# coverage
gem 'simplecov',                        :require => false

# audit + lint (CI tooling)
gem 'bundler-audit', '~> 0.9.3',        :require => false
# ruby_audit 3.x requires Ruby >= 3.1. Only the CI audit job needs it.
gem 'ruby_audit',    '~> 3.1',          :require => false if RUBY_VERSION >= '3.1.0'
gem 'standard',                         :require => false
