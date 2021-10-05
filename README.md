# HTTPI

A common interface for Ruby's HTTP libraries.

[Documentation](https://www.rubydoc.info/gems/httpi) |
[Mailing list](https://groups.google.com/forum/#!forum/httpirb)

[![Development Status](https://github.com/savon/httpi/workflows/Development/badge.svg)](https://github.com/savon/httpi/actions?workflow=Development)

## Installation

HTTPI is available through [Rubygems](https://rubygems.org/gems/httpi) and can be installed via:

```
$ gem install httpi
```

or add it to your Gemfile like this:

```
gem 'httpi', '~> 2.1.0'
```


## Usage example

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


## Documentation

Continue reading at https://www.rubydoc.info/gems/httpi
