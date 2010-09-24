require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::Curb
    #
    # Adapter for the Curb client.
    # http://rubygems.org/gems/curb
    class Curb

      # Requires the "curb" gem.
      def initialize
        require "curb"
      end

      # Returns a memoized <tt>Curl::Easy</tt> instance.
      def client
        @client ||= Curl::Easy.new
      end

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        get_request(request) { |client| client.http_get }
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        post_request(request) { |client, body| client.http_post body }
      end

    private

      def get_request(request)
        setup_client request
        yield client
        respond_with client
      end

      def post_request(request)
        request.url.query = nil if request.url.query == "wsdl"
        
        setup_client request
        yield client, request.body
        respond_with client
      end

      def setup_client(request)
        client.url = request.url.to_s
        client.timeout = request.read_timeout
        client.connect_timeout = request.open_timeout
        client.headers = request.headers
        client.verbose = false
      end

      def respond_with(client)
        Response.new client.response_code, client.headers, client.body_str
      end

    end
  end
end
