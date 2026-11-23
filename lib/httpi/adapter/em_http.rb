require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter
    # An HTTPI adapter for `EventMachine::HttpRequest`. Due to limitations of
    # the em-httprequest library, not all features are supported. In particular,
    #
    # * TLS certificate verification (HTTPS requires verify_mode :none),
    # * CA files,
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
    #
    # @deprecated em-http-request and eventmachine are no longer maintained.
    #   Use another adapter, such as +:net_http+.
    class EmHttpRequest < Base
      register :em_http, deps: %w[em-synchrony em-synchrony/em-http em-http]

      DEPRECATION_WARNING = "The em_http adapter is deprecated. " \
        "em-http-request and eventmachine are no longer maintained, and eventmachine " \
        "does not build on Ruby 4.1. Use another adapter, such as :net_http."

      TLS_VERIFICATION_ERROR = "EM-HTTP-Request cannot verify TLS certificates. " \
        "Use another adapter, or set verify_mode to :none to skip verification"

      # Prints the deprecation warning once per process, so an application that
      # sends many requests is told without its logs being flooded.
      #
      # @return [void]
      # @api private
      def self.warn_deprecation
        return if @deprecation_warned

        @deprecation_warned = true
        warn DEPRECATION_WARNING
      end

      def initialize(request)
        self.class.warn_deprecation
        @request = request
        @client = EventMachine::HttpRequest.new build_request_url(request.url), connection_options
      end

      attr_reader :client

      def cert_directory
        @cert_directory ||= "/tmp"
      end

      attr_writer :cert_directory

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        _request { |options| @client.send method, options }
      end

      private

      def _request
        options = client_options
        setup_http_auth(options) if @request.auth.http?

        if unsupported_ssl_options?
          raise NotSupportedError, "EM-HTTP-Request does not support SSL client auth"
        end

        raise NotSupportedError, TLS_VERIFICATION_ERROR if unverifiable_https?

        if @request.on_body
          raise NotSupportedError, "EM-HTTP-Request does not support response streaming"
        end

        start_time = Time.now
        respond_with yield(options), start_time
      end

      def connection_options
        options = {}

        read_or_write_timeout = @request.read_timeout || @request.write_timeout
        options[:inactivity_timeout] = read_or_write_timeout if read_or_write_timeout
        options[:connect_timeout] = @request.open_timeout if @request.open_timeout

        options[:proxy] = proxy_options if @request.proxy
        options[:tls] = {verify_peer: false} if @request.ssl?

        options
      end

      # Checks for ssl settings this adapter cannot apply. A +verify_mode+ of
      # +:none+ is the only one it honors, so anything else must raise instead
      # of being ignored. A client certificate that cannot be read still counts
      # as configured.
      #
      # @return [Boolean] true when the request sets an unsupported ssl option
      def unsupported_ssl_options?
        return false unless @request.auth.ssl?

        ssl = @request.auth.ssl
        !!(ssl.verify_mode != :none || ssl.ca_cert_file || ssl.ciphers || (ssl.cert && ssl.cert_key))
      rescue TypeError, Errno::ENOENT
        true
      end

      # Checks whether an HTTPS request expects certificate verification.
      # em-http-request cannot verify certificates reliably: it raises from
      # inside reactor callbacks and checks the hostname against a proxy
      # instead of the target. The adapter refuses these requests rather than
      # send them unverified.
      #
      # @return [Boolean] true for HTTPS unless verify_mode is +:none+
      def unverifiable_https?
        @request.ssl? && @request.auth.ssl.verify_mode != :none
      end

      def client_options
        {
          query: @request.url.query,
          head: @request.headers.to_hash,
          body: @request.body
        }
      end

      def proxy_options
        {
          host: @request.proxy.host,
          port: @request.proxy.port,
          authorization: [@request.proxy.user, @request.proxy.password]
        }
      end

      def setup_http_auth(options)
        unless @request.auth.type == :basic
          raise NotSupportedError, "EM-HTTP-Request does only support HTTP basic auth"
        end

        options[:head] ||= {}
        options[:head][:authorization] = @request.auth.credentials
      end

      def respond_with(http, start_time)
        raise TimeoutError, "EM-HTTP-Request connection timed out: #{Time.now - start_time} sec" if http.response_header.status.zero?

        Response.new http.response_header.status,
          convert_headers(http.response_header), http.response
      end

      def build_request_url(url)
        "%s://%s:%s%s" % [url.scheme, url.host, url.port, url.path]
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
    end
  end
end
