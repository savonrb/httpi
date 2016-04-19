module HTTPI
  module Adapter
    class NetHTTPMultipart < NetHTTP

      register :net_http_multipart, :deps => %w(net/http/post/multipart)

      private

      def request_client(type)
        if [:post, :put].include?(type)
          request_class = Object.const_get("Net::HTTP::#{type.to_s.capitalize}::Multipart")

          request_client = request_class.new @request.url.request_uri, @request.attachments, @request.headers

          request_client.basic_auth(*@request.auth.credentials) if @request.auth.basic?

          if @request.auth.digest?
            raise NotSupportedError, "Net::HTTP does not support HTTP digest authentication"
          end

          request_client
        else
          super(type)
        end
      end

    end
  end
end
