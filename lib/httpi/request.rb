require "uri"

module HTTPI

  # = HTTPI::Request
  #
  # Represents an HTTP request and contains various methods for customizing that request.
  class Request

    # Request accessor methods.
    ACCESSORS = [:url, :proxy, :headers, :body, :open_timeout, :read_timeout]

    # Request authentication methods.
    AUTHENTICATION = [:basic_auth]

    # Accepts a Hash of +options+ which may contain any number of ACCESSORS and/or
    # AUTHENTICATION credentials to set.
    def initialize(options = {})
      assign_accessors options
      assign_authentication options
    end

    # Sets the +url+ to access. Raises an +ArgumentError+ unless the +url+ is valid.
    def url=(url)
      @url = normalize_url! url
    end

    # Returns the +url+ to access.
    attr_reader :url

    # Sets the +proxy+ to use. Raises an +ArgumentError+ unless the +proxy+ is valid.
    def proxy=(proxy)
      @proxy = normalize_url! proxy
    end

    # Returns the +proxy+ to use.
    attr_reader :proxy

    # Returns a Hash of HTTP headers. Defaults to return an empty Hash.
    def headers
      @headers ||= {}
    end

    # Sets the Hash of HTTP headers.
    attr_writer :headers

    attr_accessor :body, :open_timeout, :read_timeout

    # Sets the HTTP basic auth credentials. Accepts an Array or two arguments for the
    # +username+ and +password+. Resets the credentials when +nil+ is passed and returns
    # an Array of credentials when no +args+ where given.
    def basic_auth(*args)
      @basic_auth = extract_credentials @basic_auth, args.flatten
    end

 private

    def assign_accessors(options)
      ACCESSORS.each { |a| send("#{a}=", options[a]) if options[a] }
    end
 
    def assign_authentication(options)
      AUTHENTICATION.each { |c| send(c, options[c]) if options[c] }
    end
 
    def normalize_url!(url)
      raise ArgumentError, "Invalid URL: #{url}" unless url.to_s =~ /^http/
      url.kind_of?(URI) ? url : URI(url)
    end

    def extract_credentials(credentials, args)
      return unless args.empty? || args.first
      args[1] ? args[0, 2] : credentials
    end

  end
end
