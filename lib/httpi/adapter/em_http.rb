module HTTPI
  module Adapter

    # An HTTPI adapter for `EventMachine::HttpRequest`. Due to limitations of
    # the em-httprequest library, not all features are supported. In particular,
    #
    # * CA files,
    # * certificate verification modes other than "none" and "peer,"
    # * NTLM authentication,
    # * digest authentication, and
    # * password-protected certificate keys
    #
    # are supported by HTTPI but not em-httprequest.
    #
    # In addition, some features of em-httprequest are not represented in HTTPI
    # and are therefore not supported. In particular,
    #
    # * SOCKS5 proxying,
    # * automatic redirect following,
    # * response streaming,
    # * file body streaming,
    # * keepalive,
    # * pipelining, and
    # * multi-request
    #
    # are supported by em-httprequest but not HTTPI.
    class EmHttpRequest

      # The default directory where certificates are saved to temporary files.
      DEFAULT_CERT_DIRECTORY = "/tmp"

      attr_accessor :cert_directory

      # @private
      def initialize(request = nil)
        @cert_directory = DEFAULT_CERT_DIRECTORY
      end

      # Performs an HTTP `GET` request.
      #
      # @param [HTTPI::Request] The request data.
      # @return [HTTPI::Response] The response data.
      def get(request)
        _request(request) { |client, options| client.get options }
      end

      # Performs an HTTP `POST` request.
      #
      # @param [HTTPI::Request] The request data.
      # @return [HTTPI::Response] The response data.
      def post(request)
        _request(request) { |client, options| client.post options }
      end

      # Performs an HTTP `PUT` request.
      #
      # @param [HTTPI::Request] The request data.
      # @return [HTTPI::Response] The response data.
      def put(request)
        _request(request) { |client, options| client.put options }
      end

      # Performs an HTTP `DELETE` request.
      #
      # @param [HTTPI::Request] The request data.
      # @return [HTTPI::Response] The response data.
      def delete(request)
        _request(request) { |client, options| client.delete options }
      end

      # Performs an HTTP `HEAD` request.
      #
      # @param [HTTPI::Request] The request data.
      # @return [HTTPI::Response] The response data.
      def head(request)
        _request(request) { |client, options| client.head options }
      end

      private

      def _request(request)
        options = client_options(request)
        client = EventMachine::HttpRequest.new("#{request.url.scheme}://#{request.url.host}:#{request.url.port}#{request.url.path}")
        setup_proxy(request, options) if request.proxy
        setup_http_auth(request, options) if request.auth.http?
        setup_ssl_auth(request.auth.ssl, options) if request.auth.ssl?

        start_time = Time.now
        respond_with yield(client, options), start_time
      end

      def client_options(request)
        {
          :query              => request.url.query,
          :connect_timeout    => request.open_timeout,
          :inactivity_timeout => request.read_timeout,
          :head               => request.headers.to_hash,
          :body               => request.body
        }
      end

      def setup_proxy(request, options)
        options[:proxy] = {
          :host          => request.proxy.host,
          :port          => request.proxy.port,
          :authorization => [request.proxy.user, request.proxy.password]
        }
      end

      def setup_http_auth(request, options)
        raise "Only HTTP Basic auth supported" unless request.auth.type == :basic

        options[:head] ||= {}
        options[:head][:authorization] = request.auth.credentials
      end

      def setup_ssl_auth(ssl, options)
        options[:ssl] = {
          :private_key_file => cert_and_key_file(ssl),
          :cert_chain_file  => cert_and_key_file(ssl),
          :verify_peer      => false  # TODO should be ssl.verify_mode == :peer
        }
      end

      def cert_and_key_file(ssl)
        contents = []
        contents << File.read(ssl.cert_key_file) if ssl.cert_key_file
        contents << File.read(ssl.cert_file) if ssl.cert_file
        contents = contents.compact.map(&:to_s).map(&:chomp).join("\n")
        return if !contents || contents.empty?

        FileUtils.mkdir_p(cert_directory)
        filename = "#{cert_directory}/em_http.#{Digest::SHA1.hexdigest contents}.tmp"
        unless File.exist?(filename)
          File.open(filename, 'w') do |f|
            f.print contents.to_s
          end
        end
        filename
      end

      def respond_with(http, start_time)
        raise TimeoutError, "Connection timed out: #{Time.now - start_time} sec" if http.response_header.status.zero?

        Response.new http.response_header.status,
          convert_headers(http.response_header), http.response
      end

      # Takes any header names with an underscore as a word separator and
      # converts the name to camel case, where words are separated by a dash.
      #
      # E.g. CONTENT_TYPE becomes Content-Type.
      def convert_headers(headers)
        return headers unless headers.keys.any? { |k| k =~ /_/ }

        result = {}

        headers.each do |k, v|
          words = k.split("_")
          key = words.map { |w| w.downcase.capitalize }.join("-")
          result[key] = v
        end

        result
      end

      class TimeoutError < StandardError; end
    end
  end
end
