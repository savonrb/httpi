HTTPI
=====

HTTPI provides a common interface for Ruby HTTP libraries.

Installation
------------

The gem is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

    $ gem install httpi

Some examples
-------------

Executing a POST request with the most basic request object:

    request = HTTPI::Request.new :url => "http://example.com"
    HTTPI.get request

Here's a POST request with a request object:

    request = HTTPI::Request.new
    request.url = "http://post.example.com"
    request.body = "send me"
  
    HTTPI.post request

And a GET request using HTTP basic auth and the Curb adapter:

    request = HTTPI::Request.new
    request.url = "http://auth.example.com"
    request.basic_auth "username", "password"
  
    HTTPI.get request, :curb

HTTPI also comes with some shortcuts. This executes a GET request:

    HTTPI.get "http://example.com"

And this executes a POST request:

    HTTPI.post "http://example.com", "<some>xml</some>"

HTTPI
-------------

The `HTTPI` module uses one of the available adapters to execute HTTP requests.
It currently supports GET and POST requests:

### GET

    .get(request, adapter = nil)
    .get(url, adapter = nil)

### POST

    .post(request, adapter = nil)
    .post(url, body, adapter = nil)

### Notice

* You can specify the adapter to use per request
* And request methods always return an `HTTPI::Response`

### More control

If you need more control over the request, you can access the HTTP client instance represented
by your adapter in a block:

    HTTPI.post request do |http|
      http.use_ssl = true  # Curb example
    end

### TODO

* Add support for HEAD, PUT and DELETE requests

HTTPI::Request
--------------

The `HTTPI::Request` serves as a common denominator of options that HTTPI adapters need to support.  
It represents an HTTP request and lets you customize various settings through these accessors:

    #url           # the URL to access
    #proxy         # the proxy server to use
    #headers       # a Hash of HTTP headers
    #body          # the HTTP request body
    #open_timeout  # the open timeout (sec)
    #read_timeout  # the read timeout (sec)

It also contains methods for setting up authentication:

    #basic_auth(username, password)   # HTTP basic auth credentials
    #digest_auth(username, password)  # HTTP digest auth credentials

### TODO

* Add support for SSL client authentication

HTTPI::Adapter
--------------

HTTPI uses adapters to support multiple HTTP libraries.
It currently contains adapters for:

* [httpclient](http://rubygems.org/gems/httpclient) ~> 2.1.5
* [curb](http://rubygems.org/gems/curb) ~> 0.7.8

By default, HTTPI uses the `HTTPClient`. But changing the default is fairly easy:

    HTTPI::Adapter.use = :curb  # or :httpclient

HTTPI::Response
---------------

As mentioned before, every request method return an `HTTPI::Response`.
It contains the response code, headers and body.

    response = HTTPI.get request
     
    response.code     # => 200
    response.headers  # => { "Content-Encoding" => "gzip" }
    response.body     # => "<!DOCTYPE HTML PUBLIC ..."

### TODO

* Return the original `HTTPI::Request` for debugging purposes
* Return the time it took to execute the request

Participate
-----------

We appreciate any help and feedback, so please get in touch!
