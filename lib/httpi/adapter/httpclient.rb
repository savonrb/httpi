require "httpi/response"
require "httpi/adapter/base"

module HTTPI
  module Adapter
    module HTTPClient
      include Base

      def setup
        require "httpclient"
      end

      def client
        @client ||= ::HTTPClient.new
      end

      def headers
        @headers ||= {}
      end

      attr_writer :headers

      def proxy
        client.proxy
      end

      def proxy=(proxy)
        client.proxy = proxy
      end

      def auth(username, password)
        client.set_auth nil, username, password
      end

      def get(url)
        respond_with client.get(url)
      end

      def post(url, body)
        respond_with client.post(url, body, headers)
      end

    private

      def respond_with(response)
        Response.new response.code, Hash[response.header.all], response.content
      end

    end
  end
end
