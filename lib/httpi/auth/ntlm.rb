require "net/ntlm"

module HTTPI
  module Auth

    # = HTTPI::Auth::NTLM
    #
    # Provides NTLM client authentication.
    class NTLM

      attr_accessor :username, :password

      def initialize(username, password)
        @username = username
        @password = password
      end

      # Returns whether NTLM configuration is present.
      def present?
        !username.nil? && !password.nil? 
      end

    end
  end
end
