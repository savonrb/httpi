require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTPClient
    #
    # Adapter for the HTTPClient client.
    # http://rubygems.org/gems/httpclient
    class HTTPClient < Base

      register :httpclient, :deps => %w(httpclient)

      def initialize(request)
        @request = request
        @client = ::HTTPClient.new
      end

      attr_reader :client

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        setup_client
        respond_with @client.request(method, @request.url, nil, @request.body, @request.headers, &@request.on_body)
      rescue OpenSSL::SSL::SSLError
        raise SSLError
      rescue Errno::ECONNREFUSED   # connection refused
        $!.extend ConnectionError
        raise
      end

      private

      def setup_client
        basic_setup

        if @request.auth.ntlm?
          raise NotSupportedError, "HTTPClient adapter does not support NTLM authentication"
        end

        setup_auth if @request.auth.http?
        setup_ssl_auth if @request.auth.ssl? || @request.ssl?
      end

      def basic_setup
        @client.proxy = @request.proxy if @request.proxy
        @client.connect_timeout = @request.open_timeout if @request.open_timeout
        @client.receive_timeout = @request.read_timeout if @request.read_timeout
      end

      def setup_auth
        @client.set_auth @request.url, *@request.auth.credentials
      end

      def setup_ssl_auth
        ssl = @request.auth.ssl

        if @request.auth.ssl?
          if ssl.ca_cert_file && ssl.verify_mode != :none
            @client.ssl_config.add_trust_ca(ssl.ca_cert_file)
          end

          # Send client-side certificate regardless of state of SSL verify mode
          @client.ssl_config.client_cert = ssl.cert
          @client.ssl_config.client_key = ssl.cert_key

          @client.ssl_config.verify_mode = ssl.openssl_verify_mode
        end

        @client.ssl_config.ssl_version = ssl.ssl_version.to_s if ssl.ssl_version
      end

      def respond_with(response)
        headers = {}
        response.header.all.each do |(header, value)|
          if headers.key?(header)
            headers[header] = Array(headers[header]) << value
          else
            headers[header] = value
          end
        end
        Response.new response.code, headers, response.content
      end

    end
  end
end
