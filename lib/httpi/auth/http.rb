module HTTPI
  module Auth
    class Credentials < Base
      attr_accessor :username, :password
      def initialize *credentials
        @username, @password = *credentials.flatten
      end

      def credentials
        [@username, @password]
      end
    end

    class Basic < Credentials
      register :basic
    end

    class Digest < Credentials
      register :digest
    end
  end
end
