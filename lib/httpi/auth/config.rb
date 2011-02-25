require "httpi/auth/ssl"

module HTTPI
  module Auth

    # = HTTPI::Auth::Config
    #
    # Manages HTTP and SSL auth configuration. Currently supports HTTP basic/digest
    # and SSL client authentication.
    class Config

      # Supported authentication types.
      TYPES = [:basic, :digest, :ssl, :ntlm]


      # Accessor for the NTLM auth credentials.
      def ntlm(*args)
        return @ntlm if args.empty?

        self.type = :ntlm
        @ntlm = args.flatten.compact
      end
      
      # Returns whether to use NTLM auth.
      def ntlm?
        type == :ntlm
      end


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

      # Returns whether to use HTTP basic or dihest auth.
      def http?
        type == :basic || type == :digest
      end

      # Returns the <tt>HTTPI::Auth::SSL</tt> object.
      def ssl
        @ssl ||= SSL.new
      end

      # Returns whether to use SSL client auth.
      def ssl?
        ssl.present?
      end

      # Shortcut method for returning the credentials for the authentication specified.
      # Returns +nil+ unless any authentication credentials were specified.
      def credentials
        return unless type
        send type
      end

      # Accessor for the authentication type in use.
      attr_accessor :type

    end
  end
end
