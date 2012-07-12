require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTPClient
    #
    # Adapter for the HTTPClient client.
    # http://rubygems.org/gems/httpclient
    class HTTPClient

      def initialize(request = nil)
      end

      # Returns a memoized <tt>HTTPClient</tt> instance.
      def client
        @client ||= ::HTTPClient.new
      end

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        do_request request do |url, headers|
          client.get url, nil, headers
        end
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        do_request request do |url, headers, body|
          client.post url, body, headers
        end
      end

      # Executes an HTTP HEAD request.
      # @see HTTPI.head
      def head(request)
        do_request request do |url, headers|
          client.head url, nil, headers
        end
      end

      # Executes an HTTP PUT request.
      # @see HTTPI.put
      def put(request)
        do_request request do |url, headers, body|
          client.put url, body, headers
        end
      end

      # Executes an HTTP DELETE request.
      # @see HTTPI.delete
      def delete(request)
        do_request request do |url, headers|
          client.delete url, headers
        end
      end

    private

      def do_request(request)
        setup_client request
        respond_with yield(request.url, request.headers, request.body)
      end

      def setup_client(request)
        basic_setup request
        setup_auth request if request.auth.http?
        setup_ssl_auth request.auth.ssl if request.auth.ssl?
      end

      def basic_setup(request)
        client.proxy = request.proxy if request.proxy
        client.connect_timeout = request.open_timeout if request.open_timeout
        client.receive_timeout = request.read_timeout if request.read_timeout
      end

      def setup_auth(request)
        client.set_auth request.url, *request.auth.credentials
      end

      def setup_ssl_auth(ssl)
        unless ssl.verify_mode == :none
          client.ssl_config.client_cert = ssl.cert
          client.ssl_config.client_key = ssl.cert_key
          client.ssl_config.client_ca = ssl.ca_cert if ssl.ca_cert_file
        end
        client.ssl_config.verify_mode = ssl.openssl_verify_mode
      end

      def respond_with(response)
        Response.new response.code, Hash[*response.header.all.flatten], response.content
      end

    end
  end
end
