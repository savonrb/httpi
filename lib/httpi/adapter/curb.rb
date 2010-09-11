require "httpi/response"
require "httpi/adapter/base"

module HTTPI
  module Adapter
    module Curb
      include Base

      def setup
        require "curb"
      end

      def client
        @client ||= Curl::Easy.new
      end

      def headers
        client.headers
      end

      def headers=(headers)
        client.headers = headers
      end

      def get(url)
        client.url = url.to_s
        client.http_get
        respond
      end

      def post(url, body)
        client.url = url.to_s
        client.http_post body
        respond
      end

    private

      def respond
        Response.new client.response_code, client.headers, client.body_str
      end

    end
  end
end
