# HTTPI

A common interface for Ruby's HTTP libraries.

[Documentation](http://httpirb.com) | [RDoc](http://rubydoc.info/gems/httpi) |
[Mailing list](https://groups.google.com/forum/#!forum/httpirb)

[![Build Status](https://secure.travis-ci.org/savonrb/httpi.png?branch=master)](http://travis-ci.org/savonrb/httpi)
[![Gem Version](https://badge.fury.io/rb/httpi.png)](http://badge.fury.io/rb/httpi)
[![Code Climate](https://codeclimate.com/github/savonrb/httpi.png)](https://codeclimate.com/github/savonrb/httpi)
[![Coverage Status](https://coveralls.io/repos/savonrb/httpi/badge.png?branch=master)](https://coveralls.io/r/savonrb/httpi)


## Installation

HTTPI is available through [Rubygems](http://rubygems.org/gems/httpi) and can be installed via:

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

Continue reading at [httpirb.com](http://httpirb.com)
