require "httpi/version"
require "httpi/request"
require "httpi/response"

# = HTTPI
#
# Executes HTTP requests using a registered adapter.
#
# Every request method accepts a variety of different arguments and returns
# an <tt>HTTPI::Response</tt>.
#
# * get(request)
# * get(url)
# * get(url, headers)
# * get(url, headers, body)
#
# If you need more control over your request, you can access the HTTP client
# instance represented by your adapter in a block.
#
#   HTTPI.get request do |http|
#     http.follow_redirect_count = 3  # httpclient-specific example
#   end
module HTTPI

  REQUEST_METHODS = [:get, :post, :head, :put, :delete]

  class << self

    # Accesor for the adapter to use.
    attr_accessor :adapter

    # Returns whether an adapter was specified.
    alias adapter? adapter

    REQUEST_METHODS.each do |method|
      class_eval %{
        def #{method}(*args)
          setup(*args) do |adapter, request|
            yield adapter.client if block_given?
            adapter.#{method} request
          end
        end
      }
    end

    # Executes an HTTP request for the given +method+.
    def request(method, *args)
      raise ArgumentError, "Unknown request method: #{method}" unless REQUEST_METHODS.include? method
      send(method, *args)
    end

  private

    def setup(request, headers = nil, body = nil)
      raise "HTTPI is missing an adapter" unless adapter

      request = Request.new(request, headers, body) unless request.kind_of? Request
      yield [adapter.new(request), request]
    end

  end
end
