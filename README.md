HTTPI
=====

HTTPI provides a common interface for Ruby HTTP libraries.

Installation
------------

The gem is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

    $ gem install httpi

Some examples
-------------

Let's create the most basic request object and execute a GET request:

    request = HTTPI::Request.new :url => "http://example.com"
    HTTPI::Client.get request

And a POST request with a request object:

    request = HTTPI::Request.new
    request.url = "http://post.example.com"
    request.body = "send me"
  
    HTTPI::Client.post request

Or a GET request using HTTP basic auth and the Curb adapter:

    request = HTTPI::Request.new
    request.url = "http://auth.example.com"
    request.basic_auth "username", "password"
  
    HTTPI::Client.get request, :curb

HTTPI also comes with some shortcuts. This executes a GET request:

    HTTPI::Client.get "http://example.com"

And here's a POST:

    HTTPI::Client.post "http://example.com", "<some>xml</some>"

HTTPI::Request
--------------

The HTTPI::Request serves as a common denominator of options that HTTPI adapters need to support.
It represents an HTTP request and lets you customize various settings:

* [url]           the URL to access
* [proxy]         the proxy server to use
* [headers]       a Hash of HTTP headers
* [body]          the HTTP request body
* [open_timeout]  the open timeout (sec)
* [read_timeout]  the read timeout (sec)

It also contains methods for setting up authentication:

* [basic_auth]  HTTP basic auth credentials

#### TODO:

* Add support for HTTP digest authentication
* Add support for SSL client authentication

HTTPI::Client
-------------

The HTTPI::Client uses one of the available adapters to execute HTTP requests.
It currently supports GET and POST requests:

### GET

    get(request, adapter = nil)
    get(url, adapter = nil)

### POST

    post(request, adapter = nil)
    post(url, body, adapter = nil)

You can specify the adapter to use per request.
Request methods always returns an HTTPI::Response.

#### TODO:

* Add support for HEAD, PUT and DELETE requests

HTTPI::Adapter
--------------

HTTPI uses adapters to support multiple HTTP libraries.
It currently contains adapters for:

* [httpclient](http://rubygems.org/gems/httpclient) ~> 2.1.5
* [curb](http://rubygems.org/gems/curb) ~> 0.7.8

By default, HTTPI uses the HTTPClient. But changing the default is fairly easy:

      HTTPI::Adapter.use = :curb

You can find a list of supported adapters via:

      HTTPI::Adapter.adapters  # returns a Hash of supported adapters

HTTPI::Response
---------------

As mentioned before, every request method return an HTTPI::Response.
It contains the response code, headers and body.

    response = HTTPI::Client.get request
     
    response.code     # => 200
    response.headers  # => { "Content-Encoding" => "gzip" }
    response.body     # => "<!DOCTYPE HTML PUBLIC ..."

#### TODO

* Return the original HTTPI::Request for debugging purposes
* Return the time it took to execute the request

Participate
-----------

We appreciate any help and feedback, so please get in touch!
