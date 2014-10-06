require "httpi/version"
require "httpi/logger"
require "httpi/request"
require "httpi/query_builder"

require "httpi/adapter/httpclient"
require "httpi/adapter/curb"
require "httpi/adapter/excon"
require "httpi/adapter/net_http"
require "httpi/adapter/net_http_persistent"
require "httpi/adapter/em_http"
require "httpi/adapter/rack"

# = HTTPI
#
# Executes HTTP requests using a predefined adapter.
# All request methods accept an <tt>HTTPI::Request</tt> and an optional adapter.
# They may also offer shortcut methods for executing basic requests.
# Also they all return an <tt>HTTPI::Response</tt>.
#
# == GET
#
#   request = HTTPI::Request.new("http://example.com")
#   HTTPI.get(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI.get("http://example.com", :curb)
#
# == POST
#
#   request = HTTPI::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#
#   HTTPI.post(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI.post("http://example.com", "<some>xml</some>", :curb)
#
# == HEAD
#
#   request = HTTPI::Request.new("http://example.com")
#   HTTPI.head(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI.head("http://example.com", :curb)
#
# == PUT
#
#   request = HTTPI::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#
#   HTTPI.put(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI.put("http://example.com", "<some>xml</some>", :curb)
#
# == DELETE
#
#   request = HTTPI::Request.new("http://example.com")
#   HTTPI.delete(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI.delete("http://example.com", :curb)
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

  DEFAULT_LOG_LEVEL = :debug

  class Error < StandardError; end
  class TimeoutError < Error; end
  class NotSupportedError < Error; end
  class NotImplementedError < Error; end

  module ConnectionError; end

  class SSLError < Error
    def initialize(message = nil, original = $!)
      super(message || original.message)
      @original = original
    end
    attr_reader :original
  end

  class << self

    def query_builder
      @query_builder || HTTPI::QueryBuilder::Flat
    end

    def query_builder=(builder)
      if builder.is_a?(Symbol)
        builder_name = builder.to_s.capitalize
        begin
          builder = HTTPI::QueryBuilder.const_get(builder_name)
        rescue NameError
          raise ArgumentError, "Invalid builder. Available builders are: [:flat, :nested]"
        end
      end
      unless builder.respond_to?(:build)
        raise ArgumentError, "Query builder object should respond to build method"
      end
      @query_builder = builder
    end

    # Executes an HTTP GET request.
    def get(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:get, request, adapter, &block)
    end

    # Executes an HTTP POST request.
    def post(*args, &block)
      request, adapter = request_and_adapter_from(args)
      request(:post, request, adapter, &block)
    end

    # Executes an HTTP HEAD request.
    def head(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:head, request, adapter, &block)
    end

    # Executes an HTTP PUT request.
    def put(*args, &block)
      request, adapter = request_and_adapter_from(args)
      request(:put, request, adapter, &block)
    end

    # Executes an HTTP DELETE request.
    def delete(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:delete, request, adapter, &block)
    end

    # Executes an HTTP request for the given +method+.
    def request(method, request, adapter = nil)
      adapter_class = load_adapter(adapter, request)

      yield adapter_class.client if block_given?
      log_request(method, request, Adapter.identify(adapter_class.class))

      response = adapter_class.request(method)

      if response &&  HTTPI::Response::RedirectResponseCodes.member?(response.code) && request.follow_redirect?
        log("Following redirect: '#{response.headers['location']}'.")
        request.url = response.headers['location']
        return request(method, request, adapter)
      end

      response
    end

    # Shortcut for setting the default adapter to use.
    def adapter=(adapter)
      Adapter.use = adapter
    end

    private

    def request_and_adapter_from(args)
      return args if args[0].kind_of? Request
      [Request.new(:url => args[0], :body => args[1]), args[2]]
    end

    def load_adapter(adapter, request)
      Adapter.load(adapter).new(request)
    end

  end
end
