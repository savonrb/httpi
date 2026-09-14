# frozen_string_literal: true

require "rack/auth/abstract/handler"
require "rack/auth/abstract/request"
require "digest/md5"
require "base64"

# Server-side HTTP Digest authentication middleware, reimplemented for the
# integration test suite.
#
# Rack 3.0 deprecated Rack::Auth::Digest and 3.1 removed it, so the test
# server can no longer use it. This is a faithful port of the removed
# implementation (rack 3-0-stable, lib/rack/auth/digest.rb), kept in the test
# suite only — httpi itself never uses it. Adapted to current style
# conventions (double quotes, snake_case private helpers) with no behavior
# changes.
#
# See https://github.com/savonrb/httpi/issues/250
class IntegrationServer
  class DigestAuth < Rack::Auth::AbstractHandler
    # IntegrationServer::DigestAuth::Nonce is the default nonce generator for
    # the IntegrationServer::DigestAuth authentication handler.
    #
    # +private_key+ needs to set to a constant string.
    #
    # +time_limit+ can be optionally set to an integer (number of seconds),
    # to limit the validity of the generated nonces.
    class Nonce
      class << self
        attr_accessor :private_key, :time_limit
      end

      def self.parse(string)
        new(*Base64.decode64(string).split(" ", 2))
      end

      def initialize(timestamp = Time.now, given_digest = nil)
        @timestamp, @given_digest = timestamp.to_i, given_digest
      end

      def to_s
        Base64.encode64("#{@timestamp} #{digest}").strip
      end

      def digest
        ::Digest::MD5.hexdigest("#{@timestamp}:#{self.class.private_key}")
      end

      def valid?
        digest == @given_digest
      end

      def stale?
        !self.class.time_limit.nil? && (Time.now.to_i - @timestamp) > self.class.time_limit
      end

      def fresh?
        !stale?
      end
    end

    class Params < Hash
      def self.parse(str)
        Params[*split_header_value(str).map do |param|
          k, v = param.split("=", 2)
          [k, dequote(v)]
        end.flatten]
      end

      def self.dequote(str) # From WEBrick::HTTPUtils
        ret = /\A"(.*)"\Z/ =~ str ? $1 : str.dup
        ret.gsub!(/\\(.)/, "\\1")
        ret
      end

      def self.split_header_value(str)
        str.scan(/\w+=(?:"[^"]+"|[^,]+)/n)
      end

      def initialize
        super

        yield self if block_given?
      end

      def [](k)
        super(k.to_s)
      end

      def []=(k, v)
        super(k.to_s, v.to_s)
      end

      UNQUOTED = ["nc", "stale"].freeze

      def to_s
        map do |k, v|
          "#{k}=#{(UNQUOTED.include?(k) ? v.to_s : quote(v))}"
        end.join(", ")
      end

      def quote(str) # From WEBrick::HTTPUtils
        "\"#{str.gsub(/["\\]/o, "\\\\\\1")}\""
      end
    end

    class Request < Rack::Auth::AbstractRequest
      def method
        @env[Rack::RACK_METHODOVERRIDE_ORIGINAL_METHOD] || @env[Rack::REQUEST_METHOD]
      end

      def digest?
        scheme == "digest"
      end

      def correct_uri?
        request.fullpath == uri
      end

      def nonce
        @nonce ||= Nonce.parse(params["nonce"])
      end

      def params
        @params ||= Params.parse(parts.last)
      end

      def respond_to?(sym, *)
        super || params.key?(sym.to_s)
      end

      def respond_to_missing?(sym, *)
        super || params.key?(sym.to_s)
      end

      def method_missing(sym, *args)
        key = sym.to_s
        return super unless params.key?(key)
        return params[key] if args.empty?

        raise ArgumentError, "wrong number of arguments (#{args.size} for 0)"
      end
    end

    # IntegrationServer::DigestAuth implements the MD5 algorithm version of
    # HTTP Digest Authentication, as per RFC 2617.
    #
    # Initialize with the [Rack] application that you want protecting,
    # and a block that looks up a plaintext password for a given username.
    #
    # +opaque+ needs to be set to a constant base64/hexadecimal string.
    attr_accessor :opaque

    attr_writer :passwords_hashed

    def initialize(app, realm = nil, opaque = nil, &authenticator)
      @passwords_hashed = nil
      if opaque.nil? && realm.respond_to?(:values_at)
        realm, opaque, @passwords_hashed = realm.values_at(:realm, :opaque, :passwords_hashed)
      end
      super(app, realm, &authenticator)
      @opaque = opaque
    end

    def passwords_hashed?
      !!@passwords_hashed
    end

    def call(env)
      auth = Request.new(env)

      unless auth.provided?
        return unauthorized
      end

      if !auth.digest? || !auth.correct_uri? || !valid_qop?(auth)
        return bad_request
      end

      if valid?(auth)
        if auth.nonce.stale?
          return unauthorized(challenge(stale: true))
        else
          env["REMOTE_USER"] = auth.username

          return @app.call(env)
        end
      end

      unauthorized
    end

    private

    QOP = "auth"

    def params(hash = {})
      Params.new do |params|
        params["realm"] = realm
        params["nonce"] = Nonce.new.to_s
        params["opaque"] = md5(opaque)
        params["qop"] = QOP

        hash.each { |k, v| params[k] = v }
      end
    end

    def challenge(hash = {})
      "Digest #{params(hash)}"
    end

    def valid?(auth)
      valid_opaque?(auth) && valid_nonce?(auth) && valid_digest?(auth)
    end

    def valid_qop?(auth)
      auth.qop == QOP
    end

    def valid_opaque?(auth)
      md5(opaque) == auth.opaque
    end

    def valid_nonce?(auth)
      auth.nonce.valid?
    end

    def valid_digest?(auth)
      pw = @authenticator.call(auth.username)
      pw && Rack::Utils.secure_compare(digest(auth, pw), auth.response)
    end

    def md5(data)
      # codeql[rb/weak-sensitive-data-hashing]: MD5 is mandated by RFC 2617 for HTTP Digest auth; this middleware only exists for the integration tests.
      ::Digest::MD5.hexdigest(data)
    end

    def kd(secret, data)
      md5 "#{secret}:#{data}"
    end

    def a1(auth, password)
      "#{auth.username}:#{auth.realm}:#{password}"
    end

    def a2(auth)
      "#{auth.method}:#{auth.uri}"
    end

    def digest(auth, password)
      password_hash = passwords_hashed? ? password : md5(a1(auth, password))

      kd password_hash, "#{auth.nonce}:#{auth.nc}:#{auth.cnonce}:#{QOP}:#{md5 a2(auth)}"
    end
  end
end
