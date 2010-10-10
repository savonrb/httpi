require "httpi/version"
require "httpi/request"
require "httpi/adapter"

# = HTTPI
#
# Executes HTTP requests using a predefined adapter.
# All request methods accept an <tt>HTTPI::Request</tt> and an optional adapter.
# They may also offer shortcut methods for executing basic requests.
# Also they all return an <tt>HTTPI::Response</tt>.
#
# == GET
#
#   request = HTTPI::Request.new :url => "http://example.com"
#   HTTPI.get request, :httpclient
#
# === Shortcuts
#
#   HTTPI.get "http://example.com", :curb
#
# == POST
#
#   request = HTTPI::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#   
#   HTTPI.post request, :httpclient
#
# === Shortcuts
#
#   HTTPI.post "http://example.com", "<some>xml</some>", :curb
#
# == HEAD
#
#   request = HTTPI::Request.new :url => "http://example.com"
#   HTTPI.head request, :httpclient
#
# === Shortcuts
#
#   HTTPI.head "http://example.com", :curb
#
# == PUT
#
#   request = HTTPI::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#   
#   HTTPI.put request, :httpclient
#
# === Shortcuts
#
#   HTTPI.put "http://example.com", "<some>xml</some>", :curb
#
# == DELETE
#
#   request = HTTPI::Request.new :url => "http://example.com"
#   HTTPI.delete request, :httpclient
#
# === Shortcuts
#
#   HTTPI.delete "http://example.com", :curb
#
# == More control
#
# If you need more control over your request, you can access the HTTP client
# instance represented by your adapter in a block.
#
#   HTTPI.get request do |http|
#     http.follow_redirect_count = 3  # HTTPClient example
#   end
module HTTPI

  REQUEST_METHODS = [:get, :post, :head, :put, :delete]

  class << self

    # Executes an HTTP GET request.
    def get(request, adapter = nil)
      request = Request.new :url => request if request.kind_of? String
      
      with request, adapter do |adapter|
        yield adapter.client if block_given?
        adapter.get request
      end
    end

    # Executes an HTTP POST request.
    def post(*args)
      request, adapter = request_and_adapter_from(args)
      
      with request, adapter do |adapter|
        yield adapter.client if block_given?
        adapter.post request
      end
    end

    # Executes an HTTP HEAD request.
    def head(request, adapter = nil)
      request = Request.new :url => request if request.kind_of? String
      
      with request, adapter do |adapter|
        yield adapter.client if block_given?
        adapter.head request
      end
    end

    # Executes an HTTP PUT request.
    def put(*args)
      request, adapter = request_and_adapter_from(args)
      
      with request, adapter do |adapter|
        yield adapter.client if block_given?
        adapter.put request
      end
    end

    # Executes an HTTP DELETE request.
    def delete(request, adapter = nil)
      request = Request.new :url => request if request.kind_of? String
      
      with request, adapter do |adapter|
        yield adapter.client if block_given?
        adapter.delete request
      end
    end

    # Executes an HTTP request for the given +method+.
    def request(method, request, adapter = nil)
      raise ArgumentError, "Invalid request method: #{method}" unless REQUEST_METHODS.include? method
      send method, request, adapter
    end

  private

    # Checks whether +args+ contains of an <tt>HTTPI::Request</tt> or a URL
    # and a request body plus an optional adapter and returns an Array with
    # an <tt>HTTPI::Request</tt> and (if given) an adapter.
    def request_and_adapter_from(args)
      return args if args[0].kind_of? Request
      [Request.new(:url => args[0], :body => args[1]), args[2]]
    end

    # Expects a +request+ and an +adapter+ (defaults to <tt>Adapter.use</tt>)
    # and yields a new instance of the adapter to a given block.
    def with(request, adapter)
      adapter ||= Adapter.use
      yield Adapter.find(adapter).new(request)
    end

  end
end
