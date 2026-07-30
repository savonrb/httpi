source 'https://rubygems.org'
gemspec

gem 'jruby-openssl',                                       :platforms => :jruby

gem 'public_suffix', '~> 4.0'

# http clients
gem 'httpclient',          '~> 2.3',    :require => false
# curb 1.0 moved to the TypedData API; the 0.x line no longer compiles on
# Ruby 4.1, which removed the untyped Data_Get_Struct. TruffleRuby, however,
# crashes its reference-processor thread on curb 1.x's TypedData finalizers
# ("dead handle" in rb_tr_rtypeddata_run_finalizer), so keep 0.x there.
if RUBY_ENGINE == 'truffleruby'
  gem 'curb',              '~> 0.9',    :require => false
else
  gem 'curb',              '~> 1.3',    :require => false, :platforms => [:ruby]
end
# eventmachine (em-http-request's transitive dependency) still uses the untyped
# Data_Wrap_Struct API, which Ruby 4.1 removed, and 1.2.7 is the last release.
# Skip the em adapter's dependencies there so bundle install keeps working.
if RUBY_VERSION < '4.1'
  gem 'em-http-request',                :require => false, :platforms => [:ruby]
  gem 'em-synchrony',                   :require => false, :platforms => [:ruby, :jruby]
end
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
