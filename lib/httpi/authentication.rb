module HTTPI

  # = HTTPI::Authentication
  #
  # Represents HTTP authentication. Currently supports HTTP basic/digest and SSL
  # client authentication.
  class Authentication

    # Supported authentication types.
    TYPES = [:basic, :digest]

    # Accessor for the HTTP basic auth credentials.
    def basic(*args)
      return @basic if args.empty?
      
      self.type = :basic
      @basic = args.flatten.compact
    end

    # Returns whether to use HTTP basic auth.
    def basic?
      type == :basic
    end

    # Accessor for the HTTP digest auth credentials.
    def digest(*args)
      return @digest if args.empty?
      
      self.type = :digest
      @digest = args.flatten.compact
    end

    # Returns whether to use HTTP digest auth.
    def digest?
      type == :digest
    end

    # Shortcut method for returning the credentials for the authentication specified.
    # Returns +nil+ unless any authentication credentials were specified.
    def credentials
      return unless type
      send type
    end

    # Accessor for the authentication type in use.
    attr_accessor :type

    # Expects a Hash of +args+ to assign.
    def mass_assign(args)
      TYPES.each { |key| send(key, args[key]) if args[key] }
    end

  end
end
