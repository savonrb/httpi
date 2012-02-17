require "uri"
require "httpi/auth/config"
require "rack/utils"

module HTTPI

  # = HTTPI::Request
  #
  # Represents an HTTP request and contains various methods for customizing that request.
  class Request

    # Available attribute writers.
    ATTRIBUTES = [:url, :proxy, :headers, :body, :open_timeout, :read_timeout]

    # Accepts a Hash of +args+ to mass assign attributes and authentication credentials.
    def initialize(args = {})
      if args.kind_of? String
        self.url = args
      elsif args.kind_of?(Hash) && !args.empty?
        mass_assign args
      end
    end

    # Sets the +url+ to access. Raises an +ArgumentError+ unless the +url+ is valid.
    def url=(url)
      @url = normalize_url! url
      auth.basic @url.user, @url.password || '' if @url.user
    end

    # Returns the +url+ to access.
    attr_reader :url

    # Sets the +proxy+ to use. Raises an +ArgumentError+ unless the +proxy+ is valid.
    def proxy=(proxy)
      @proxy = normalize_url! proxy
    end

    # Returns the +proxy+ to use.
    attr_reader :proxy

    # Returns whether to use SSL.
    def ssl?
      return @ssl unless @ssl.nil?
      !!(url.to_s =~ /^https/)
    end

    # Sets whether to use SSL.
    attr_writer :ssl

    # Returns a Hash of HTTP headers. Defaults to return an empty Hash.
    def headers
      @headers ||= Rack::Utils::HeaderHash.new
    end

    # Sets the Hash of HTTP headers.
    def headers=(headers)
      @headers = Rack::Utils::HeaderHash.new(headers)
    end

    # Adds a header information to accept gzipped content.
    def gzip
      headers["Accept-Encoding"] = "gzip,deflate"
    end

    attr_accessor :open_timeout, :read_timeout
    attr_reader :body

    # Sets a body request given a String or a Hash.
    def body=(params)
      @body = params.kind_of?(Hash) ? Rack::Utils.build_query(params) : params
    end

    # Returns the <tt>HTTPI::Authentication</tt> object.
    def auth
      @auth ||= Auth::Config.new
    end

    # Returns whether any authentication credentials were specified.
    def auth?
      !!auth.type
    end

    # Expects a Hash of +args+ to assign.
    def mass_assign(args)
      ATTRIBUTES.each { |key| send("#{key}=", args[key]) if args[key] }
    end

  private

    # Expects a +url+, validates its validity and returns a +URI+ object.
    def normalize_url!(url)
      raise ArgumentError, "Invalid URL: #{url}" unless url.to_s =~ /^http/
      url.kind_of?(URI) ? url : URI(url)
    end

  end
end
