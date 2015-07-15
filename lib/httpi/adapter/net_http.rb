require "uri"

require "httpi/adapter/base"
require "httpi/response"
require 'net/ntlm'
require 'kconv'

module HTTPI
  module Adapter

    # = HTTPI::Adapter::NetHTTP
    #
    # Adapter for the Net::HTTP client.
    # http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/
    class NetHTTP < Base

      register :net_http, :deps => %w(net/https)

      def initialize(request)
        @request = request
        @client = create_client
      end

      attr_reader :client

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        # Determine if Net::HTTP supports the method using reflection
        unless Net::HTTP.const_defined?(:"#{method.to_s.capitalize}") &&
            Net::HTTP.const_get(:"#{method.to_s.capitalize}").class == Class

          raise NotSupportedError, "Net::HTTP does not support "\
            "#{method.to_s.upcase}"
        end

        do_request(method) do |http, http_request|
          http_request.body = @request.body
          if @request.on_body then
            http.request(http_request) do |res|
              res.read_body do |seg|
                @request.on_body.call(seg)
              end
            end
          else
            http.request http_request
          end
        end
      rescue OpenSSL::SSL::SSLError
        raise SSLError
      rescue Errno::ECONNREFUSED   # connection refused
        $!.extend ConnectionError
        raise
      end

      private

      def create_client
        proxy_url = @request.proxy || URI("")
        proxy = Net::HTTP::Proxy(proxy_url.host, proxy_url.port, proxy_url.user, proxy_url.password)
        proxy.new(@request.url.host, @request.url.port)
      end

      def do_request(type)
        setup_client
        setup_ssl_auth if @request.auth.ssl?

        respond_with(@client.start do |http|
          if @request.auth.ntlm?
            # first yield request is to authenticate (exchange secret and auth)...
            t1 = Net::NTLM::Message::Type1.new()
            @request.headers["Authorization"] = "NTLM #{t1.encode64}"
            resp = respond_with(yield(http, request_client(:head)))

            if resp.headers["WWW-Authenticate"] =~ /(NTLM|Negotiate) (.+)/
              msg = $2
              t2 = Net::NTLM::Message.decode64(msg)
              t3 = t2.response({:user => @request.auth.ntlm[0], :password => @request.auth.ntlm[1]}, {:ntlmv2 => true})
              @request.headers["Authorization"] = "NTLM #{t3.encode64}"
            end
            # second yield request below is made with the authorization.
          end

          yield http, request_client(type)
        end)
      end

      def setup_client
        @client.use_ssl = @request.ssl?
        @client.open_timeout = @request.open_timeout if @request.open_timeout
        @client.read_timeout = @request.read_timeout if @request.read_timeout
      end

      def setup_ssl_auth
        ssl = @request.auth.ssl

        unless ssl.verify_mode == :none
          @client.key = ssl.cert_key
          @client.cert = ssl.cert
          @client.ca_file = ssl.ca_cert_file if ssl.ca_cert_file
        end

        @client.verify_mode = ssl.openssl_verify_mode
        @client.ssl_version = ssl.ssl_version if ssl.ssl_version
      end

      def request_client(type)
        request_class = Net::HTTP.const_get(:"#{type.to_s.capitalize}")

        request_client = request_class.new @request.url.request_uri, @request.headers
        request_client.basic_auth *@request.auth.credentials if @request.auth.basic?

        request_client
      end

      def respond_with(response)
        headers = response.to_hash
        headers.each do |key, value|
          headers[key] = value[0] if value.size <= 1
        end
        body = (response.body.kind_of?(Net::ReadAdapter) ? "" : response.body)
        Response.new response.code, headers, body
      end

    end
  end
end
