require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::Excon
    #
    # Adapter for the Excon client.
    # https://github.com/geemus/excon
    class Excon < Base

      register :excon, :deps => %w(excon)

      def initialize(request)
        @request = request
        @client  = ::Excon::Connection.new client_opts
      end

      attr_reader :client

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        respond_with @client.send(method)
      rescue ::Excon::Errors::SocketError => e
        case e.message
        when /verify certificate/
          raise SSLError
        else
          $!.extend ConnectionError
        end
        raise
      end

      private

      def client_opts
        url  = @request.url
        ssl  = @request.auth.ssl

        opts = {
          :host => url.host,
          :path => url.path,
          :port => url.port.to_s,
          :query => url.query,
          :scheme => url.scheme,
          :headers => @request.headers,
          :body => @request.body
        }

        if @request.auth.digest?
          raise NotSupportedError, "excon does not support HTTP digest authentication"
        elsif @request.auth.ntlm?
          raise NotSupportedError, "excon does not support NTLM authentication"
        end

        opts[:user], opts[:password] = *@request.auth.credentials if @request.auth.basic?
        opts[:connect_timeout] = @request.open_timeout if @request.open_timeout
        opts[:read_timeout]    = @request.read_timeout if @request.read_timeout
        opts[:response_block]  = @request.on_body if @request.on_body
        opts[:proxy]           = @request.proxy if @request.proxy

        if ssl.verify_mode == :peer
          opts[:ssl_verify_peer] = true
          opts[:ssl_ca_file] = ssl.ca_cert_file if ssl.ca_cert_file
          opts[:client_cert] = ssl.cert     if ssl.cert
          opts[:client_key]  = ssl.cert_key if ssl.cert_key
          opts[:ssl_version] = ssl.ssl_version if ssl.ssl_version
        end

        opts
      end

      def respond_with(response)
        Response.new response.status, response.headers, response.body
      end

    end
  end
end
