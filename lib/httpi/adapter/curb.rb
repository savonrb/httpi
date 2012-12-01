require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::Curb
    #
    # Adapter for the Curb client.
    # http://rubygems.org/gems/curb
    class Curb < Base

      register :curb, :deps => %w(curb)

      def initialize(request)
        @request = request
        @client = Curl::Easy.new
      end

      attr_reader :client

      def request(method)
        unless REQUEST_METHODS.include? method
          raise NotSupportedError, "Curb does not support custom HTTP methods"
        end

        arguments = ["http_#{method}"]
        if [:put, :post].include? method
          arguments << (@request.body || "")
        end

        do_request { |client| client.send(*arguments) }
      rescue Curl::Err::SSLCACertificateError
        raise SSLError
      rescue Curl::Err::SSLPeerCertificateError
        raise SSLError
      rescue Curl::Err::ConnectionFailedError  # connection refused
        $!.extend ConnectionError
        raise
      end

      private

      def do_request
        setup_client
        yield @client
        respond_with @client
      end

      def setup_client
        basic_setup
        setup_http_auth if @request.auth.http?
        setup_gssnegotiate_auth if @request.auth.gssnegotiate?
        setup_ssl_auth if @request.auth.ssl?
      end

      def basic_setup
        @client.url = @request.url.to_s
        @client.proxy_url = @request.proxy.to_s if @request.proxy
        @client.timeout = @request.read_timeout if @request.read_timeout
        @client.connect_timeout = @request.open_timeout if @request.open_timeout
        @client.headers = @request.headers.to_hash
        @client.verbose = false
      end

      def setup_http_auth
        @client.http_auth_types = @request.auth.type
        @client.username, @client.password = *@request.auth.credentials
      end

      def setup_gssnegotiate_auth
        @client.http_auth_types = @request.auth.type
        # The curl man page (http://curl.haxx.se/docs/manpage.html) says that
        # you have to specify a fake username when using Negotiate auth, and
        # they use ':' in their example.
        @client.username = ':'
      end

      def setup_ssl_auth
        ssl = @request.auth.ssl

        unless ssl.verify_mode == :none
          @client.cert_key = ssl.cert_key_file
          @client.cert = ssl.cert_file
          @client.cacert = ssl.ca_cert_file if ssl.ca_cert_file
          @client.certtype = ssl.cert_type.to_s.upcase
        end

        @client.ssl_verify_peer = ssl.verify_mode == :peer
        @client.ssl_version = case ssl.ssl_version
          when :TLSv1 then 1
          when :SSLv2 then 2
          when :SSLv3 then 3
        end
      end

      def respond_with(client)
        status, headers = parse_header_string(client.header_str)
        Response.new client.response_code, headers, client.body_str
      end

      # Borrowed from Webmock's Curb adapter:
      # http://github.com/bblimke/webmock/blob/master/lib/webmock/http_lib_adapters/curb.rb
      def parse_header_string(header_string)
        status, headers = nil, {}
        return [status, headers] unless header_string

        header_string.split(/\r\n/).each do |header|
          if header =~ %r|^HTTP/1.[01] \d\d\d (.*)|
            status = $1
          else
            parts = header.split(':', 2)
            unless parts.empty?
              parts[1].strip! unless parts[1].nil?
              if headers.has_key?(parts[0])
                headers[parts[0]] = [headers[parts[0]]] unless headers[parts[0]].kind_of? Array
                headers[parts[0]] << parts[1]
              else
                headers[parts[0]] = parts[1]
              end
            end
          end
        end

        [status, headers]
      end

    end
  end
end
