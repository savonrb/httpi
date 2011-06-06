HTTPI [![Build Status](http://travis-ci.org/rubiii/httpi.png)](http://travis-ci.org/rubiii/httpi)
=====

HTTPI provides a common interface for Ruby HTTP clients.


Adapters
--------

HTTPI provides a standard request and response object, as well as unified request methods.  
Adapters can use and build upon these basics to establish a common interface.

```
$ gem install httpi-net-http
```

Adapter for [Net/HTTP](http://www.ruby-doc.org/stdlib/libdoc/net/http/rdoc/index.html).


Interface
---------

The `HTTPI` module contains the HTTP request methods `get`, `post`, `head`, `put` and `delete`.  
Every request method accepts the same combination of arguments and returns an `HTTPI::Response`.

``` ruby
HTTPI.get(url, headers = nil, body = nil)
```

You can provide a request URL (String or URI) and optionally add a Hash of request headers and a body.

``` ruby
HTTPI.get  "http://example.com"
HTTPI.put  "http://example.com", { "Accept-Encoding" => "utf-8" }
HTTPI.post "http://example.com", { "Accept-Encoding" => "utf-8" }, "request body"
```

For more advanced requests where you need to configure e.g. a proxy or some kind of authentication,
you can use an `HTTPI::Request`.

``` ruby
request = HTTPI::Request.new
request.url = "http://example.com"
request.headers = { "Accept-Encoding" => "utf-8" }
request.body = "request body"

HTTPI.post(request)
```


HTTPI::Request
--------------

`HTTPI::Request` is little more than a value object representing an HTTP request.

#### URL

``` ruby
request.url = "http://example.com"
request.url # => #<URI::HTTP:0x101c1ab18 URL:http://example.com>
```

#### Proxy

``` ruby
request.proxy = "http://example.com"
request.proxy # => #<URI::HTTP:0x101c1ab18 URL:http://example.com>
```

#### Headers

``` ruby
request.headers["Accept-Charset"] = "utf-8"
request.headers = { "Accept-Charset" => "utf-8" }
request.headers # => { "Accept-Charset" => "utf-8" }
```

#### Body

``` ruby
request.body = "some data"
request.body # => "some data"
```

#### Open timeout

``` ruby
request.open_timeout = 30 # sec
```

#### Read timeout

``` ruby
request.read_timeout = 30 # sec
```


HTTPI::Auth
-----------

`HTTPI::Auth` provides methods for setting up HTTP basic and digest authentication and can be
accessed through the `HTTPI::Request`.

``` ruby
request.auth.basic("username", "password")   # HTTP basic auth credentials
request.auth.digest("username", "password")  # HTTP digest auth credentials
```


HTTPI::Auth::SSL
----------------

`HTTPI::Auth::SSL` provides SSL client authentication.

``` ruby
request.auth.ssl.cert_key_file     = "client_key.pem"   # the private key file to use
request.auth.ssl.cert_key_password = "C3rtP@ssw0rd"     # the key file's password
request.auth.ssl.cert_file         = "client_cert.pem"  # the certificate file to use
request.auth.ssl.ca_cert_file      = "ca_cert.pem"      # the ca certificate file to use
request.auth.ssl.verify_mode       = :none              # or one of [:peer, :fail_if_no_peer_cert, :client_once]
```


HTTPI::Response
---------------

Every HTTP request (like for example `HTTPI.get`) returns an `HTTPI::Response`. This object
contains the response code, headers and body.

``` ruby
response = HTTPI.get("http://example.com")

response.code     # => 200
response.headers  # => { "Content-Encoding" => "gzip" }
response.body     # => "<!DOCTYPE HTML PUBLIC ...>"
```

The `HTTPI::Response#body` method handles gzipped and
[DIME](http://en.wikipedia.org/wiki/Direct_Internet_Message_Encapsulation) encoded responses.


Conventions
-----------

Adapters should follow certain conventions.

#### Naming

Adapter libraries should follow the Rubygems naming convention for gems based on other gems.  
They should start with `httpi` followed by the name of the client library, separated by dashes.

Some examples are:

* httpi-net-http
* httpi-httpclient
* httpi-curb

#### Versioning

HTTPI uses [Semantic Versioning](http://semver.org) to provide a stable API.

Adapters should follow the major version of the HTTPI interface. For example, every 1.x.x version
of the `httpi-net-http` adapter should use any 1.x.x version of the HTTPI interface. This can
be specified as:

``` ruby
Gem::Specification.new do |s|
  s.name    = "httpi-net-http"
  s.version = "1.3.1"

  s.add_dependency "httpi", "~> 1.0"
end
```

`~> 1.0` could be changed to a higher version like `1.5`, but both adapter and interface should
have the same major version number.
