require "uri"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::NetHTTP
    #
    # Adapter for the Net::HTTP client.
    # http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/
    class NetHTTP

      # Requires the "net/https" library and sets up a new client.
      def initialize(request)
        require "net/https"
        self.client = new_client request
      end

      attr_reader :client

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        do_request :get, request do |http, get|
          http.request get
        end
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        do_request :post, request do |http, post|
          post.body = request.body
          http.request post
        end
      end

      # Executes an HTTP HEAD request.
      # @see HTTPI.head
      def head(request)
        do_request :head, request do |http, head|
          http.request head
        end
      end

      # Executes an HTTP PUT request.
      # @see HTTPI.put
      def put(request)
        do_request :put, request do |http, put|
          put.body = request.body
          http.request put
        end
      end

      # Executes an HTTP DELETE request.
      # @see HTTPI.delete
      def delete(request)
        do_request :delete, request do |http, delete|
          http.request delete
        end
      end

    private

      attr_writer :client

      def new_client(request)
        proxy = request.proxy || URI("")
        Net::HTTP::Proxy(proxy.host, proxy.port).new request.url.host, request.url.port
      end

      def do_request(type, request)
        setup_client request
        
        respond_with(client.start do |http|
          yield http, request_client(type, request)
        end)
      end

      def setup_client(request)
        client.use_ssl = request.ssl?
        client.open_timeout = request.open_timeout
        client.read_timeout = request.read_timeout
      end

      def request_client(type, request)
        request_class = case type
          when :get    then Net::HTTP::Get
          when :post   then Net::HTTP::Post
          when :head   then Net::HTTP::Head
          when :put    then Net::HTTP::Put
          when :delete then Net::HTTP::Delete
        end
        
        request_client = request_class.new request.url.request_uri, request.headers
        request_client = auth_setup request_client, request if request.auth?
        request_client
      end

      def auth_setup(request_client, request)
        request_client.basic_auth *request.auth.credentials if request.auth.basic?
        request_client
      end

      def respond_with(response)
        Response.new response.code, response.to_hash, response.body
      end

    end
  end
end
