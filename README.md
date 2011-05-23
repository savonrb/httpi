HTTPI [![Build Status](http://travis-ci.org/rubiii/httpi.png)](http://travis-ci.org/rubiii/httpi)
=====

HTTPI provides a common interface for Ruby's HTTP clients. It contains both
a request and response object as well as unified request methods and is supposed
to be used by adapter libraries.


Known adapters
--------------

```
$ gem install httpi-net-http
```

Adapter for [Net/HTTP](http://www.ruby-doc.org/stdlib/libdoc/net/http/rdoc/index.html).

```
$ gem install httpi-httpclient
```

Adapter for the [httpclient](https://rubygems.org/gems/httpclient) library.

```
$ gem install httpi-curb
```

Adapter for the [curb](https://rubygems.org/gems/curb) library.
