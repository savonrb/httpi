HTTPI [![Build Status](https://secure.travis-ci.org/rubiii/httpi.png)](http://travis-ci.org/rubiii/httpi)
=====

HTTPI provides a common interface for Ruby HTTP libraries.

[Bugs](http://github.com/rubiii/httpi/issues) | [RDoc](http://rubydoc.info/gems/httpi/frames)

Installation
------------

HTTPI is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

```
$ gem install httpi
```


Getting started
---------------

In order to provide a common interface, HTTPI provides the `HTTPI::Request` object for you to
configure your request. Here's a very simple GET request.

``` ruby
request = HTTPI::Request.new("http://example.com")
HTTPI.get request
```

To execute a POST request, you may want to specify a payload.

``` ruby
request = HTTPI::Request.new
request.url = "http://post.example.com"
request.body = "some data"

HTTPI.post request
```


HTTPI
-----

The `HTTPI` module uses one of the available adapters to execute HTTP requests.

#### GET

``` ruby
HTTPI.get(request, adapter = nil)
HTTPI.get(url, adapter = nil)
```

#### POST

``` ruby
HTTPI.post(request, adapter = nil)
HTTPI.post(url, body, adapter = nil)
```

#### HEAD

``` ruby
HTTPI.head(request, adapter = nil)
HTTPI.head(url, adapter = nil)
```

#### PUT

``` ruby
HTTPI.put(request, adapter = nil)
HTTPI.put(url, body, adapter = nil)
```

#### DELETE

``` ruby
HTTPI.delete(request, adapter = nil)
HTTPI.delete(url, adapter = nil)
```

#### Notice

* You can specify the adapter to use per request
* And request methods always return an `HTTPI::Response`

#### More control

If you need more control over the request, you can access the HTTP client instance
represented by your adapter in a block:

``` ruby
HTTPI.post request do |http|
  http.use_ssl = true  # Curb example
end
```


HTTPI::Adapter
--------------

HTTPI uses adapters to support multiple HTTP libraries.
It currently contains adapters for:

* [httpclient](http://rubygems.org/gems/httpclient) ~> 2.1.5
* [curb](http://rubygems.org/gems/curb) ~> 0.7.8
* [net/http](http://ruby-doc.org/stdlib/libdoc/net/http/rdoc)

You can manually specify the adapter to use via:

``` ruby
HTTPI.adapter = :curb  # or one of [:httpclient, :net_http]
```

If you don't specify which adapter to use, HTTPI try to load HTTPClient, then Curb and finally NetHTTP.

#### Notice

HTTPI does not force you to install any of these libraries. If you'd like to use on of the more advanced
libraries (HTTPClient or Curb), you have to make sure they're in your LOAD_PATH. HTTPI will then load the
library when executing HTTP requests.


HTTPI::Request
--------------

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

`HTTPI::Auth` supports HTTP basic and digest authentication.

``` ruby
request.auth.basic("username", "password")   # HTTP basic auth credentials
request.auth.digest("username", "password")  # HTTP digest auth credentials
```

For experimental NTLM authentication, please use the [httpi-ntlm](rubygems.org/gems/httpi-ntml)
gem and provide feedback.

``` ruby
request.auth.ntlm("username", "password")    # NTLM auth credentials
```

HTTPI::Auth::SSL
----------------

`HTTPI::Auth::SSL` manages SSL client authentication.

``` ruby
request.auth.ssl.cert_key_file     = "client_key.pem"   # the private key file to use
request.auth.ssl.cert_key_password = "C3rtP@ssw0rd"     # the key file's password
request.auth.ssl.cert_file         = "client_cert.pem"  # the certificate file to use
request.auth.ssl.ca_cert_file      = "ca_cert.pem"      # the ca certificate file to use
request.auth.ssl.verify_mode       = :none              # or one of [:peer, :fail_if_no_peer_cert, :client_once]
```


HTTPI::Response
---------------

Every request returns an `HTTPI::Response`. It contains the response code, headers and body.

``` ruby
response = HTTPI.get request

response.code     # => 200
response.headers  # => { "Content-Encoding" => "gzip" }
response.body     # => "<!DOCTYPE HTML PUBLIC ...>"
```

The `response.body` handles gzipped and [DIME](http://en.wikipedia.org/wiki/Direct_Internet_Message_Encapsulation) encoded responses.

#### TODO

* Return the original `HTTPI::Request` for debugging purposes
* Return the time it took to execute the request


Logging
-------

HTTPI by default logs each HTTP request to STDOUT using a log level of :debug.

``` ruby
HTTPI.log       = false     # disable logging
HTTPI.logger    = MyLogger  # change the logger
HTTPI.log_level = :info     # change the log level
```
