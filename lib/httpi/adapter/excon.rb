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
      rescue ::Excon::Error::Timeout
        $!.extend TimeoutError
        raise
      end

      private

      def client_opts
        url  = @request.url
        ssl  = @request.auth.ssl

        opts = {
          :host => url.host,
          :path => url.path,
          :port => url.port,
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
        opts[:write_timeout]   = @request.write_timeout if @request.write_timeout
        opts[:response_block]  = @request.on_body if @request.on_body
        opts[:proxy]           = @request.proxy if @request.proxy

        case ssl.verify_mode
        when :peer
          opts[:ssl_verify_peer] = true
          opts[:ssl_ca_file] = ssl.ca_cert_file if ssl.ca_cert_file
          opts[:certificate] = ssl.cert.to_pem     if ssl.cert
          opts[:private_key] = ssl.cert_key.to_pem if ssl.cert_key
        when :none
          opts[:ssl_verify_peer] = false
        end

        opts[:ssl_version] = ssl.ssl_version if ssl.ssl_version

        opts
      end

      def respond_with(response)
        headers = response.headers.dup
        if (cookies = response.data[:cookies]) && !cookies.empty?
          headers["Set-Cookie"] = cookies
        end
        Response.new response.status, headers, response.body
      end

    end
  end
end
