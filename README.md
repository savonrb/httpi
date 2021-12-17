# HTTPI

A common interface for Ruby's HTTP libraries.

[Documentation](https://www.rubydoc.info/gems/httpi)

[![Development](https://github.com/savonrb/httpi/actions/workflows/development.yml/badge.svg)](https://github.com/savonrb/httpi/actions/workflows/development.yml)

## Installation

HTTPI is available through [Rubygems](https://rubygems.org/gems/httpi) and can be installed via:

    $ gem install httpi

or add it to your Gemfile like this:

    gem 'httpi', '~> 3.0.0'

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

### Rack Mock Adapter

To use the Rack mock adapter, please add the `rack` gem to your gemfile.

### SOCKS Proxy Support

To use the the SOCKS proxy support, please add the `socksify` gem to your gemfile, and add the following code:

``` ruby
require 'socksify'
require 'socksify/http'
```

to your project.

## Documentation

Continue reading at https://www.rubydoc.info/gems/httpi
