### 2.3.0

* Improvement: [#136](https://github.com/savonrb/httpi/pull/136) Allow setting of ssl versions depending on what versions OpenSSL provides at runtime.

### 2.2.8 (edge)

* Improvement: [#133](https://github.com/savonrb/httpi/pull/133) Add 'query' to available attribute writers so it can be set with 'new'
* Fix: [#132](https://github.com/savonrb/httpi/pull/132) Fix a few warnings, among which a circular require

### 2.2.7

* Fix: [#131](https://github.com/savonrb/httpi/pull/131) Excon adapter should respect :ssl_version

### 2.2.6

* Fix: [#128](https://github.com/savonrb/httpi/pull/128) Fix for libcURL crash on some ssystems.

### 2.2.5

* Feature: [#123](https://github.com/savonrb/httpi/pull/123) Don't warn about missing rubyntlm gem if it is optional. Thanks to [PChambino](https://github.com/PChambino)

### 2.2.4

* Fix: [#120](https://github.com/savonrb/httpi/pull/120) fixed an unintended crash when an incompatible version of NTLM was required. Thanks to [hubrix](https://github.com/hubrix)

### 2.2.3

* Feature: [#117](https://github.com/savonrb/httpi/pull/117) Follow 302 redirects
* Feature: [#118](https://github.com/savonrb/httpi/pull/118) Support for SSL certificate private keys in formats other than RSA

### 2.2.2

* Feature: [#118](https://github.com/savonrb/httpi/pull/118) Support for other SSL certificate keys, not only RSA. Thanks to [Novikov Andrey](https://github.com/Envek).

### 2.2.1 (2014-06-11)

* Fix: [#116](https://github.com/savonrb/httpi/pull/116) Fix NoMethodError when not using NTLM.

### 2.2.0 (2014-05-22)

* Fix: [#111](https://github.com/savonrb/httpi/pull/111) Check rubyntlm version in a 0.4.0+ compatible way. Thanks to [Carl Zulauf](https://github.com/carlzulauf).
* Fix: [#109](https://github.com/savonrb/httpi/pull/109) SSL version is set regardless of SSL auth settings. Thanks to [Mike Campbell](https://github.com/mikecmpbll).
* Feature: [#108](https://github.com/savonrb/httpi/pull/108) Make `rubyntlm` gem, an optional dependency. Thanks to [Tim Jarratt](https://github.com/tjarratt).

### 2.1.0 (2013-07-22)

* Feature: [#75](https://github.com/savonrb/httpi/pull/75) Rack adapter.

* Feature: [#91](https://github.com/savonrb/httpi/pull/91) New excon adapter.

* Feature: [#92](https://github.com/savonrb/httpi/pull/92) New net-http-persistent adapter.

* Feature: [#87](https://github.com/savonrb/httpi/pull/87) NTLM support with full domain and server authentication.

* Feature: [#71](https://github.com/savonrb/httpi/pull/71) chunked responses.

* Fix: [#81](https://github.com/savonrb/httpi/issues/81) send SSL client certificate
  even when `:ssl_verify_mode` is set to `:none`.

* Fix: [#69](https://github.com/savonrb/httpi/issues/69) truncating response headers.

* Fix: [#88](https://github.com/savonrb/httpi/issues/88) timeout and proxy options
  are now properly passed to the EM-HTTP-Request client.

* Fix: [#69](https://github.com/savonrb/httpi/issues/69) Fixes a problem where the response headers were truncated.

* Fix: [#90](https://github.com/savonrb/httpi/issues/90) we now raise an error if
  you try to use Net::HTTP with HTTP digest authentication, because Net::HTTP does
  not support digest authentication.

### 2.0.2 (2013-01-26)

* Feature: Changed `HTTPI::Request#set_cookies` to accept an Array of `HTTPI::Cookie`
  objects as well as any object that responds to `cookies` (like an `HTTPI::Response`).

### 2.0.1 (2013-01-25)

* Fix: [#72](https://github.com/savonrb/httpi/pull/72) standardized response
  headers from all adapters.

### 2.0.0 (2012-12-16)

* Feature: [#66](https://github.com/savonrb/httpi/pull/66) adds a `query` method
  to the request.

* Fix: [#68](https://github.com/savonrb/httpi/issues/68) request does not yield
  adapter client.

### 2.0.0.rc1 (2012-11-10)

* Feature: [#63](https://github.com/savonrb/httpi/pull/63) adds support for
  EventMachine::HttpRequest. Additional information at [#40](https://github.com/savonrb/httpi/pull/40).

* Feature: Added support for custom HTTP methods to clients supporting this feature.
  It's limited to the `:httpclient` and `:em_http` adapter.

    ``` ruby
    HTTPI.request(:custom, request)
    ```

* Improvement: [#64](https://github.com/savonrb/httpi/pull/64) adds support for
  specifying the SSL version to use.

* Improvement: Log to `$stdout` (instead of `STDOUT`) using a default log level of
  `:debug` (instead of `:warn`).

* Improvement: In case an adapter doesn't support a general feature, we now raise
  an `HTTPI::NotSupportedError`.

* Improvement: Added support for adding custom adapters.

* Refactoring: Simplified the adapter interface.

### 1.1.1 (2012-07-01)

* Fix: [#56](https://github.com/savonrb/httpi/pull/56) ensures that the "Cookie"
  header is not set to nil.

### 1.1.0 (2012-06-26)

* Refactoring: Moved code that sets the cookies from the last response for the
  next request from Savon to `HTTPI::Request#set_cookies`.

### 1.0.0 (2012-06-07)

* Feature: [#48](https://github.com/savonrb/httpi/pull/48) @jheiss added support
  for HTTP Negotiate/SPNEGO authentication (curb-specific).

* Fix: [#53](https://github.com/savonrb/httpi/issues/53) fixed an issue where
  `HTTPI.log_level` did not do anything at all.

### 0.9.7 (2012-04-26)

* Fix: Merged [pull request 49](https://github.com/savonrb/httpi/pull/49) so that cert
  and cert_key can be manually set.

* Fix: Stop auto-detecting gzipped responses by inspecting the response body to allow
  response compression only.

### 0.9.6 (2012-02-23)

* Feature: Merged [pull request 46](https://github.com/savonrb/httpi/pull/46) to support
  request body Hashes. Fixes [issue 45](https://github.com/savonrb/httpi/issues/45).

    ``` ruby
    request.body = { :foo => :bar, :baz => :foo }  # => "foo=bar&baz=foo"
    ```

* Feature: Merged [pull request 43](https://github.com/savonrb/httpi/pull/43) to allow
  proxy authentication with net/http.

* Feature: Merged [pull request 42](https://github.com/savonrb/httpi/pull/42) which sets up
  HTTP basic authentication if user information is present in the URL.

* Fix: Merged [pull request 44](https://github.com/savonrb/httpi/pull/44) to fix
  [issue 26](https://github.com/savonrb/httpi/issues/26) and probably also
  [issue 32](https://github.com/savonrb/httpi/issues/32) - SSL client authentication.

### 0.9.5 (2011-06-30)

* Improvement: Moved support for NTLM authentication into a separate gem.
  Since NTLM support caused quite some problems for people who didn't even
  need it, I decided to move it into httpi-ntlm until it's stable.

### 0.9.4 (2011-05-15)

* Fix: issues [34](https://github.com/savonrb/httpi/issues/34) and
  [29](https://github.com/savonrb/httpi/issues/29) - replaced the dependency
  on `ntlm-http` with a dependency on `pyu-ntlm-http` which comes with quite
  a few bugfixes.

* Fix: Setting the default adapter did not always load the adapter's client library.

* Improvement: Added a shortcut method to set the default adapter to use.

      HTTPI.adapter = :net_http

### 0.9.3 (2011-04-28)

* Fix: [issue 31](https://github.com/savonrb/httpi/issues/31) missing headers when using httpclient.

* Fix: [issue 30](https://github.com/savonrb/httpi/issues/30) fix for using SSL with Net::HTTP.

### 0.9.2 (2011-04-05)

* Fix: issues [161](https://github.com/savonrb/savon/issues/161) and [165](https://github.com/savonrb/savon/issues/165)
  reported at [savonrb/savon](https://github.com/savonrb/savon).

### 0.9.1 (2011-04-04)

* Fix: [issue 25](https://github.com/savonrb/httpi/issues/22) problem with HTTPI using the Net::HTTP adapter [hakanensari].

### 0.9.0 (2011-03-08)

* Feature: improved the adapter loading process ([d4a091](https://github.com/savonrb/httpi/commit/d4a091)) [rubiii].

  Instead of using HTTPClient as the default and falling back to NetHTTP, the loading process now does the following:

  1. Check if either HTTPClient, Curb or NetHTTP are already defined.
     If any one of those is defined, use it.

  2. Try to require HTTPClient, Curb and NetHTTP at last.
     If any one of those can be required, use it.

  Of course you can still manually specify the adapter to use.

* Fix: [issue 22](https://github.com/savonrb/httpi/issues/22) argument error on logging adapter warning [rubiii].

* Fix: [issue 23](https://github.com/savonrb/httpi/issues/23) the HTTPI.log method now works as expected [rubiii].

### 0.8.0 (2011-03-07)

* Feature: added support for NTLM authentication ([96ceb1](https://github.com/savonrb/httpi/commit/96ceb1)) [MattHall].

  You should now be able to use NTLM authentication by specifying your credentials via `HTTPI::Auth::Config#ntlm`:

      request = HTTPI::Request.new
      request.auth.ntlm "username", "password"

* Improvement: changed the default log level to :warn ([d01591](https://github.com/savonrb/httpi/commit/d01591))
  and log at appropriate levels ([21ee1b](https://github.com/savonrb/httpi/commit/21ee1b)) [ichverstehe].

* Fix: [issue 18](https://github.com/savonrb/httpi/issues/18) don't mask exceptions in decoded_gzip_body
  ([f3811b](https://github.com/savonrb/httpi/commit/f3811b)) [fj].
