require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::Curb
    #
    # Adapter for the Curb client.
    # http://rubygems.org/gems/curb
    class Curb

      # Requires the "curb" gem.
      def initialize(request = nil)
        require "curb"
      end

      # Returns a memoized <tt>Curl::Easy</tt> instance.
      def client
        @client ||= Curl::Easy.new
      end

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        do_request(request) { |client| client.http_get }
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        do_request(request) { |client, body| client.http_post body }
      end

      # Executes an HTTP HEAD request.
      # @see HTTPI.head
      def head(request)
        do_request(request) { |client| client.http_head }
      end

      # Executes an HTTP PUT request.
      # @see HTTPI.put
      def put(request)
        do_request(request) { |client, body| client.http_put body }
      end

      # Executes an HTTP DELETE request.
      # @see HTTPI.delete
      def delete(request)
        do_request(request) { |client| client.http_delete }
      end

    private

      def do_request(request)
        setup_client request
        yield client
        respond_with client
      end

      def setup_client(request)
        basic_setup request
        setup_auth request if request.auth?
      end

      def basic_setup(request)
        client.url = request.url.to_s
        client.timeout = request.read_timeout if request.read_timeout
        client.connect_timeout = request.open_timeout if request.open_timeout
        client.headers = request.headers
        client.verbose = false
      end

      def setup_auth(request)
        client.http_auth_types = request.auth.type
        client.username, client.password = *request.auth.credentials
      end

      def respond_with(client)
        Response.new client.response_code, client.headers, client.body_str
      end

    end
  end
end
