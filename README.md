HTTPI
=====

HTTPI provides a common interface for Ruby HTTP libraries.

[Wishlist](http://httpi.uservoice.com) | [Bugs](http://github.com/rubiii/httpi/issues) | [Docs](http://rubydoc.info/gems/httpi/frames)

Installation
------------

The gem is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

    $ gem install httpi

Some examples
-------------

Executing a POST request with the most basic request object:

    request = HTTPI::Request.new "http://example.com"
    HTTPI.get request

Here's a POST request with a request object:

    request = HTTPI::Request.new
    request.url = "http://post.example.com"
    request.body = "send me"
  
    HTTPI.post request

And a GET request using HTTP basic auth and the Curb adapter:

    request = HTTPI::Request.new
    request.url = "http://auth.example.com"
    request.auth.basic "username", "password"
  
    HTTPI.get request, :curb

HTTPI also comes with some shortcuts. This executes a PUT request:

    HTTPI.put "http://example.com", "<some>xml</some>"

And this executes a DELETE request:

    HTTPI.delete "http://example.com"

HTTPI
-------------

The `HTTPI` module uses one of the available adapters to execute HTTP requests.

### GET

    HTTPI.get(request, adapter = nil)
    HTTPI.get(url, adapter = nil)

### POST

    HTTPI.post(request, adapter = nil)
    HTTPI.post(url, body, adapter = nil)

### HEAD

    HTTPI.head(request, adapter = nil)
    HTTPI.head(url, adapter = nil)

### PUT

    HTTPI.put(request, adapter = nil)
    HTTPI.put(url, body, adapter = nil)

### DELETE

    HTTPI.delete(request, adapter = nil)
    HTTPI.delete(url, adapter = nil)

### Notice

* You can specify the adapter to use per request
* And request methods always return an `HTTPI::Response`

### More control

If you need more control over the request, you can access the HTTP client instance represented
by your adapter in a block:

    HTTPI.post request do |http|
      http.use_ssl = true  # Curb example
    end

HTTPI::Request
--------------

The `HTTPI::Request` serves as a common denominator of options that HTTPI adapters need to support.  
It represents an HTTP request and lets you customize various settings through the following methods:

    #url           # the URL to access
    #proxy         # the proxy server to use
    #ssl           # whether to use SSL
    #headers       # a Hash of HTTP headers
    #body          # the HTTP request body
    #open_timeout  # the open timeout (sec)
    #read_timeout  # the read timeout (sec)

### Usage example

    request = HTTPI::Request.new
    request.url = "http://example.com"
    request.read_timeout = 30

HTTPI::Authentication
---------------------

`HTTPI::Authentication` supports HTTP basic and digest authentication.

    #basic(username, password)   # HTTP basic auth credentials
    #digest(username, password)  # HTTP digest auth credentials

### Usage example

    request = HTTPI::Request.new
    request.auth.basic "username", "password"

### TODO

* Add support for SSL client authentication
* Add support for NTLM authentication

HTTPI::Adapter
--------------

HTTPI uses adapters to support multiple HTTP libraries.
It currently contains adapters for:

* [httpclient](http://rubygems.org/gems/httpclient) ~> 2.1.5
* [curb](http://rubygems.org/gems/curb) ~> 0.7.8
* [net/http](http://ruby-doc.org/stdlib/libdoc/net/http/rdoc)

By default, HTTPI uses the `HTTPClient`. But changing the default is fairly easy:

    HTTPI::Adapter.use = :curb  # or one of [:httpclient, :net_http]

HTTPI::Response
---------------

As mentioned before, every request method return an `HTTPI::Response`.
It contains the response code, headers and body.

    response = HTTPI.get request
     
    response.code     # => 200
    response.headers  # => { "Content-Encoding" => "gzip" }
    response.body     # => "<!DOCTYPE HTML PUBLIC ...>"

### TODO

* Return the original `HTTPI::Request` for debugging purposes
* Return the time it took to execute the request

Participate
-----------

Any help and feedback appreciated. So please get in touch!
