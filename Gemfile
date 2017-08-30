source 'https://rubygems.org'
gemspec

gem 'jruby-openssl',                                       :platforms => :jruby

# compatibility restrictions for http clients under existing travis test environments
gem 'public_suffix', '~> 2.0'   # or remove rubies < 2.1 from travis.yml

# http clients
gem 'httpclient',          '~> 2.3',    :require => false
gem 'curb',                '~> 0.8',    :require => false, :platforms => :ruby
gem 'em-http-request',                  :require => false, :platforms => [:ruby, :jruby]
gem 'em-synchrony',                     :require => false, :platforms => [:ruby, :jruby]
gem 'excon',               '~> 0.21',   :require => false, :platforms => [:ruby, :jruby]
gem 'net-http-persistent', '~> 2.8',    :require => false
gem 'http',                             :require => false

# coverage
gem 'simplecov',                        :require => false
gem 'coveralls',                        :require => false
