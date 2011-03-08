## 0.9.0 (2011-03-08)

* Feature: improved the adapter loading process ([d4a091](https://github.com/rubiii/savon/commit/d4a091)) [rubiii].

  Instead of using HTTPClient as the default and falling back to NetHTTP, the loading process now does the following:

  1. Check if either HTTPClient, Curb or NetHTTP are already defined.
     If any one of those is defined, use it.

  2. Try to require HTTPClient, Curb and NetHTTP at last.
     If any one of those can be required, use it.

  Of course you can still manually specify the adapter to use.

* Fix: [issue 22](https://github.com/rubiii/httpi/issues/22) argument error on logging adapter warning [rubiii].

* Fix: [issue 23](https://github.com/rubiii/httpi/issues/23) the HTTPI.log method now works as expected [rubiii].

## 0.8.0 (2011-03-07)

* Feature: added support for NTLM authentication ([96ceb1](https://github.com/rubiii/savon/commit/96ceb1)) [MattHall].

  You should now be able to use NTLM authentication by specifying your credentials via `HTTPI::Auth::Config#ntlm`:

      request = HTTPI::Request.new
      request.auth.ntlm "username", "password"

* Improvement: changed the default log level to :warn ([d01591](https://github.com/rubiii/savon/commit/d01591))
  and log at appropriate levels ([21ee1b](https://github.com/rubiii/savon/commit/21ee1b)) [ichverstehe].

* Fix: [issue 18](https://github.com/rubiii/httpi/issues/18) don't mask exceptions in decoded_gzip_body
  ([f3811b](https://github.com/rubiii/savon/commit/f3811b)) [fj].
