require "httpi/request"
require "httpi/adapter"

module HTTPI

  # = HTTPI::Client
  #
  # Executes HTTP requests using one of the adapters.
  class Client
    class << self

      # Executes an HTTP GET request and returns an <tt>HTTPI::Response</tt>.
      #
      # ==== Example
      #
      # Accepts an <tt>HTTPI::Request</tt> and an optional adapter:
      #
      #   request = HTTPI::Request.new :url => "http://example.com"
      #   HTTPI::Client.get request, :httpclient
      #
      # ==== Shortcut
      #
      # You can also just pass a URL and an optional adapter if you don't
      # need to configure the request:
      #
      #   HTTPI::Client.get "http://example.com", :curb
      #
      # ==== More control
      #
      # If you need more control over the request, you can access the HTTP
      # client instance represented by your adapter in a block.
      #
      #   HTTPI::Client.get request do |http|
      #     http.follow_redirect_count = 3  # HTTPClient example
      #   end
      def get(request, adapter = nil)
        request = Request.new :url => request if request.kind_of? String
        
        with adapter do |adapter|
          yield adapter.client if block_given?
          adapter.get request
        end
      end

      # Executes an HTTP POST request and returns an <tt>HTTPI::Response</tt>.
      #
      # ==== Example
      #
      # Accepts an <tt>HTTPI::Request</tt> and an optional adapter:
      #
      #   request = HTTPI::Request.new
      #   request.url = "http://example.com"
      #   request.body = "<some>xml</some>"
      #   
      #   HTTPI::Client.post request, :httpclient
      #
      # ==== Shortcut
      #
      # You can also just pass a URL, a request body and an optional adapter
      # if you don't need to configure the request:
      #
      #   HTTPI::Client.post "http://example.com", "<some>xml</some>", :curb
      #
      # ==== More control
      #
      # If you need more control over the request, you can access the HTTP
      # client instance represented by your adapter in a block.
      #
      #   HTTPI::Client.post request do |http|
      #     http.use_ssl = true  # Curb example
      #   end
      def post(*args)
        request, adapter = extract_post_args(args)
        
        with adapter do |adapter|
          yield adapter.client if block_given?
          adapter.post request
        end
      end

    private

      # Checks whether +args+ contains of an <tt>HTTPI::Request</tt> or a URL
      # and a request body plus an optional adapter and returns an Array with
      # an <tt>HTTPI::Request</tt> and (if given) an adapter.
      def extract_post_args(args)
        return args if args[0].kind_of? Request
        [Request.new(:url => args[0], :body => args[1]), args[2]]
      end

      # Accepts an +adapter+ (defaults to <tt>Adapter.use</tt>) and yields a
      # new instance of the adapter to a given block.
      def with(adapter)
        adapter ||= Adapter.use
        yield Adapter.find(adapter).new
      end

    end
  end
end
