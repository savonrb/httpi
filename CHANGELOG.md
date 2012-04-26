## 0.9.7 (2012-04-26)

* Fix: Merged [pull request 49](https://github.com/rubiii/httpi/pull/49) so that cert
  and cert_key can be manually set.

* Fix: Stop auto-detecting gzipped responses by inspecting the response body to allow
  response compression only.

## 0.9.6 (2012-02-23)

* Feature: Merged [pull request 46](https://github.com/rubiii/httpi/pull/46) to support
  request body Hashes. Fixes [issue 45](https://github.com/rubiii/httpi/issues/45).

    ``` ruby
    request.body = { :foo => :bar, :baz => :foo }  # => "foo=bar&baz=foo"
    ```

* Feature: Merged [pull request 43](https://github.com/rubiii/httpi/pull/43) to allow
  proxy authentication with net/http.

* Feature: Merged [pull request 42](https://github.com/rubiii/httpi/pull/42) which sets up
  HTTP basic authentication if user information is present in the URL.

* Fix: Merged [pull request 44](https://github.com/rubiii/httpi/pull/44) to fix
  [issue 26](https://github.com/rubiii/httpi/issues/26) and probably also
  [issue 32](https://github.com/rubiii/httpi/issues/32) - SSL client authentication.

## 0.9.5 (2011-06-30)

* Improvement: Moved support for NTLM authentication into a separate gem.
  Since NTLM support caused quite some problems for people who didn't even
  need it, I decided to move it into httpi-ntlm until it's stable.

## 0.9.4 (2011-05-15)

* Fix: issues [34](https://github.com/rubiii/httpi/issues/34) and
  [29](https://github.com/rubiii/httpi/issues/29) - replaced the dependency
  on `ntlm-http` with a dependency on `pyu-ntlm-http` which comes with quite
  a few bugfixes.

* Fix: Setting the default adapter did not always load the adapter's client library.

* Improvement: Added a shortcut method to set the default adapter to use.

      HTTPI.adapter = :net_http

## 0.9.3 (2011-04-28)

* Fix: [issue 31](https://github.com/rubiii/httpi/issues/31) missing headers when using httpclient.

* Fix: [issue 30](https://github.com/rubiii/httpi/issues/30) fix for using SSL with Net::HTTP.

## 0.9.2 (2011-04-05)

* Fix: issues [161](https://github.com/rubiii/savon/issues/161) and [165](https://github.com/rubiii/savon/issues/165)
  reported at [rubiii/savon](https://github.com/rubiii/savon).

## 0.9.1 (2011-04-04)

* Fix: [issue 25](https://github.com/rubiii/httpi/issues/22) problem with HTTPI using the Net::HTTP adapter [hakanensari].

## 0.9.0 (2011-03-08)

* Feature: improved the adapter loading process ([d4a091](https://github.com/rubiii/httpi/commit/d4a091)) [rubiii].

  Instead of using HTTPClient as the default and falling back to NetHTTP, the loading process now does the following:

  1. Check if either HTTPClient, Curb or NetHTTP are already defined.
     If any one of those is defined, use it.

  2. Try to require HTTPClient, Curb and NetHTTP at last.
     If any one of those can be required, use it.

  Of course you can still manually specify the adapter to use.

* Fix: [issue 22](https://github.com/rubiii/httpi/issues/22) argument error on logging adapter warning [rubiii].

* Fix: [issue 23](https://github.com/rubiii/httpi/issues/23) the HTTPI.log method now works as expected [rubiii].

## 0.8.0 (2011-03-07)

* Feature: added support for NTLM authentication ([96ceb1](https://github.com/rubiii/httpi/commit/96ceb1)) [MattHall].

  You should now be able to use NTLM authentication by specifying your credentials via `HTTPI::Auth::Config#ntlm`:

      request = HTTPI::Request.new
      request.auth.ntlm "username", "password"

* Improvement: changed the default log level to :warn ([d01591](https://github.com/rubiii/httpi/commit/d01591))
  and log at appropriate levels ([21ee1b](https://github.com/rubiii/httpi/commit/21ee1b)) [ichverstehe].

* Fix: [issue 18](https://github.com/rubiii/httpi/issues/18) don't mask exceptions in decoded_gzip_body
  ([f3811b](https://github.com/rubiii/httpi/commit/f3811b)) [fj].
