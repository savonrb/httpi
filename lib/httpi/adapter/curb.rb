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
        setup_http_auth request if request.auth.http?
        setup_ssl_auth request.auth.ssl if request.auth.ssl?
      end

      def basic_setup(request)
        client.url = request.url.to_s
        client.proxy_url = request.proxy.to_s if request.proxy
        client.timeout = request.read_timeout if request.read_timeout
        client.connect_timeout = request.open_timeout if request.open_timeout
        client.headers = request.headers
        client.verbose = false
      end

      def setup_http_auth(request)
        client.http_auth_types = request.auth.type
        client.username, client.password = *request.auth.credentials
      end

      def setup_ssl_auth(ssl)
        client.cert_key = ssl.cert_key_file
        client.cert = ssl.cert_file
        client.cacert = ssl.ca_cert_file if ssl.ca_cert_file
        client.ssl_verify_peer = ssl.verify_mode == :peer
      end

      def respond_with(client)
        Response.new client.response_code, client.headers, client.body_str
      end

    end
  end
end
