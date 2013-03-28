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
        unless REQUEST_METHODS.include? method
          raise NotSupportedError, "Net::HTTP does not support custom HTTP methods"
        end
        do_request(method) do |http, http_request|
          http_request.body = @request.body
          if @request.on_body then
            perform(http, http_request) do |res|
              res.read_body do |seg|
                @request.on_body.call(seg)
              end
            end
          else
            perform(http, http_request)
          end
        end
      rescue OpenSSL::SSL::SSLError
        raise SSLError
      rescue Errno::ECONNREFUSED   # connection refused
        $!.extend ConnectionError
        raise
      end

      private

      def perform(http, http_request, &block)
        http.request http_request, &block
      end

      def create_client
        proxy_url = @request.proxy || URI("")
        proxy = Net::HTTP::Proxy(proxy_url.host, proxy_url.port, proxy_url.user, proxy_url.password)
        proxy.new(@request.url.host, @request.url.port)
      end

      def do_request(type, &requester)
        setup
        response = @client.start do |http|
          negotiate_ntlm_auth(http, &requester) if @request.auth.ntlm?
          requester.call(http, request_client(type))
        end
        respond_with(response)
      end

      def setup
        setup_client
        setup_ssl_auth if @request.auth.ssl?
      end

      def negotiate_ntlm_auth(http, &requester)
        # first call request is to authenticate (exchange secret and auth)...
        ntlm_message_type1 = Net::NTLM::Message::Type1.new
        @request.headers["Authorization"] = "NTLM #{ntlm_message_type1.encode64}"

        auth_response = respond_with(requester.call(http, request_client(:head)))

        if auth_response.headers["WWW-Authenticate"] =~ /(NTLM|Negotiate) (.+)/
          auth_token = $2
          ntlm_message = Net::NTLM::Message.decode64(auth_token)
          ntlm_response = ntlm_message.response({:user => @request.auth.ntlm[0],
                                                 :password => @request.auth.ntlm[1]},
                                                 {:ntlmv2 => true})
          # Finally add header of Authorization
          @request.headers["Authorization"] = "NTLM #{ntlm_response.encode64}"
        end

        nil
      end

      def setup_client
        @client.use_ssl = @request.ssl?
        @client.open_timeout = @request.open_timeout if @request.open_timeout
        @client.read_timeout = @request.read_timeout if @request.read_timeout
      end

      def setup_ssl_auth
        ssl = @request.auth.ssl

        unless ssl.verify_mode == :none
          @client.ca_file = ssl.ca_cert_file if ssl.ca_cert_file
        end

        # Send client-side certificate regardless of state of SSL verify mode
        @client.key = ssl.cert_key
        @client.cert = ssl.cert

        @client.verify_mode = ssl.openssl_verify_mode
        @client.ssl_version = ssl.ssl_version if ssl.ssl_version
      end

      def request_client(type)
        request_class = case type
          when :get    then Net::HTTP::Get
          when :post   then Net::HTTP::Post
          when :head   then Net::HTTP::Head
          when :put    then Net::HTTP::Put
          when :delete then Net::HTTP::Delete
        end

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
