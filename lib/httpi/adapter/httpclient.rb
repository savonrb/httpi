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

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method, request)
        setup_client(request)

        options = { :header => request.headers, :body => request.body }
        respond_with client.request(method, request.url, options)
      end

    private

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
        client.ssl_config.ssl_version = ssl.ssl_version if ssl.ssl_version
      end

      def respond_with(response)
        Response.new response.code, Hash[*response.header.all.flatten], response.content
      end

    end
  end
end
