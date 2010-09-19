require "httpi/response"

module HTTPI
  module Adapter
    class HTTPClient

      def initialize
        require "httpclient"
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
        client = client_for request
        respond_with yield(client, request.url, request.headers)
      end

      def post_request(request)
        client = client_for request
        respond_with yield(client, request.url, request.headers, request.body)
      end

      def client_for(request)
        client = ::HTTPClient.new
        client.proxy = request.proxy if request.proxy
        client.connect_timeout = request.open_timeout
        client.receive_timeout = request.read_timeout
        client
      end

      def respond_with(response)
        Response.new response.code, Hash[response.header.all], response.content
      end

    end
  end
end
