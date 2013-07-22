module HTTPI
  module Adapter

    # = HTTPI::Adapter::NetHTTPPersistent
    #
    # Adapter for the Net::HTTP::Persistent client.
    # http://docs.seattlerb.org/net-http-persistent/Net/HTTP/Persistent.html
    class NetHTTPPersistent < NetHTTP

      register :net_http_persistent, :deps => %w(net/http/persistent)

      private

      def create_client
        Net::HTTP::Persistent.new thread_key
      end

      def perform(http, http_request, &on_body)
        http.request @request.url, http_request, &on_body
      end

      def do_request(type, &requester)
        setup
        response = requester.call @client, request_client(type)
        respond_with(response)
      end

      def setup_client
        if @request.auth.ntlm?
          raise NotSupportedError, "Net::HTTP-Persistent does not support NTLM authentication"
        end

        @client.open_timeout = @request.open_timeout if @request.open_timeout
        @client.read_timeout = @request.read_timeout if @request.read_timeout
      end

      def thread_key
        @request.url.host.split(/\W/).reject{|p|p == ""}.join('-')
      end

    end
  end
end
