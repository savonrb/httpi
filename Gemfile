source 'https://rubygems.org'
gemspec

gem 'jruby-openssl',                                       :platforms => :jruby

# http clients
gem 'httpclient',          '~> 2.3',    :require => false
gem 'curb',                '~> 0.8',    :require => false, :platforms => :ruby
gem 'em-http-request',                  :require => false, :platforms => [:ruby, :jruby]
gem 'em-synchrony',                     :require => false, :platforms => [:ruby, :jruby]
gem 'excon',               '~> 0.21',   :require => false, :platforms => [:ruby, :jruby]
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.1')
  gem 'net-http-persistent', '~> 3.0',  :require => false
else
  gem 'net-http-persistent', '~> 2.8',  :require => false
end
gem 'http',                '~> 1.0.4',  :require => false
gem 'addressable',         '~> 2.4.0'
gem 'mime-types',          '~> 2.6.2'

# coverage
gem 'simplecov',                        :require => false
gem 'coveralls',                        :require => false
