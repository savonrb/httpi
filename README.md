HTTPI [![Build Status](https://secure.travis-ci.org/savonrb/httpi.png)](http://travis-ci.org/savonrb/httpi)
=====

HTTPI provides a common interface for Ruby's HTTP libraries.

[Documentation](http://httpirb.com) | [RDoc](http://rubydoc.info/gems/httpi) |
[Mailing list](https://groups.google.com/forum/#!forum/httpirb)

Installation
------------

HTTPI is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

```
$ gem install httpi
```


Introduction
------------

``` ruby
require "httpi"

# create a request object
request = HTTPI::Request.new
request.url = "http://example.com"

# and pass it to a request method
HTTPI.get(request)

# use a specific adapter per request
HTTPI.get(request, :curb)

# or specify a global adapter to use
HTTPI.adapter = :httpclient

# and execute arbitary requests
HTTPI.request(:custom, request)
```

Documentation
-------------

Continue reading at [httpirb.com](http://httpirb.com)
