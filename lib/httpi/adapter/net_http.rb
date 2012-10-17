require "uri"

require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::NetHTTP
    #
    # Adapter for the Net::HTTP client.
    # http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/
    class NetHTTP < Base

      register :net_http, :deps => %w(net/https)

      def initialize(request)
        @client = create_client(request)
      end

      attr_accessor :client

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method, request)
        unless REQUEST_METHODS.include? method
          raise NotSupportedError, "Net::HTTP does not support custom HTTP methods"
        end

        do_request method, request do |http, http_request|
          http_request.body = request.body
          http.request http_request
        end
      end

    private

      def create_client(request)
        proxy_url = request.proxy || URI("")
        proxy = Net::HTTP::Proxy(proxy_url.host, proxy_url.port, proxy_url.user, proxy_url.password)
        proxy.new(request.url.host, request.url.port)
      end

      def do_request(type, request)
        setup_client request
        setup_ssl_auth request.auth.ssl if request.auth.ssl?

        respond_with(client.start do |http|
          yield http, request_client(type, request)
        end)
      end

      def setup_client(request)
        client.use_ssl = request.ssl?
        client.open_timeout = request.open_timeout if request.open_timeout
        client.read_timeout = request.read_timeout if request.read_timeout
      end

      def setup_ssl_auth(ssl)
        unless ssl.verify_mode == :none
          client.key = ssl.cert_key
          client.cert = ssl.cert
          client.ca_file = ssl.ca_cert_file if ssl.ca_cert_file
        end
        client.verify_mode = ssl.openssl_verify_mode
        client.ssl_version = ssl.ssl_version if ssl.ssl_version
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
        request_client.basic_auth *request.auth.credentials if request.auth.basic?

        request_client
      end

      def respond_with(response)
        headers = response.to_hash
        headers.each { |key, value| headers[key] = value[0] }
        Response.new response.code, headers, response.body
      end

    end
  end
end
