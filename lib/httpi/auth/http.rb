module HTTPI
  module Auth
    class Credentials
      attr_accessor :username, :password
      def initialize *credentials
        @username, @password = *credentials.flatten
      end

      def credentials
        [@username, @password]
      end
    end

    class Basic < Credentials
      HTTPI::Auth.register self, :basic
    end

    class Digest < Credentials
      HTTPI::Auth.register self, :digest
    end
  end
end
