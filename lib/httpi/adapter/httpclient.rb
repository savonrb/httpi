require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTPClient
    #
    # Adapter for the HTTPClient client.
    # http://rubygems.org/gems/httpclient
    class HTTPClient

      def initialize
        require "httpclient"
      end

      def client
        @client ||= ::HTTPClient.new
      end

      def get(request)
        get_request request do |client, url, headers|
          client.get url, nil, headers
        end
      end

      def post(request)
        post_request request do |client, url, headers, body|
          client.post url, body, headers
        end
      end

    private

      def get_request(request)
        setup_client request
        respond_with yield(client, request.url, request.headers)
      end

      def post_request(request)
        setup_client request
        respond_with yield(client, request.url, request.headers, request.body)
      end

      def setup_client(request)
        client.proxy = request.proxy if request.proxy
        client.connect_timeout = request.open_timeout
        client.receive_timeout = request.read_timeout
      end

      def respond_with(response)
        Response.new response.code, Hash[response.header.all], response.content
      end

    end
  end
end
