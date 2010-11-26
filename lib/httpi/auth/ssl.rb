require "openssl"

module HTTPI
  module Auth

    # = HTTPI::Auth::SSL
    #
    # Provides SSL client authentication.
    class SSL

      VERIFY_MODES = [:none, :peer, :fail_if_no_peer_cert, :client_once]

      # Returns whether SSL configuration is present.
      def present?
        (verify_mode == :none) || (cert && cert_key)
      rescue TypeError, Errno::ENOENT
        false
      end

      # Accessor for the cert key file to validate SSL certificates.
      attr_accessor :cert_key_file

      # Accessor for the cert key password to validate SSL certificates.
      attr_accessor :cert_key_password

      # Accessor for the cert file to validate SSL connections.
      attr_accessor :cert_file

      # Accessor for the cacert file to validate SSL certificates.
      attr_accessor :ca_cert_file

      # Returns the SSL verify mode. Defaults to <tt>:peer</tt>.
      def verify_mode
        @verify_mode ||= :peer
      end

      # Sets the SSL verify mode. Expects one of <tt>HTTPI::Auth::SSL::VERIFY_MODES</tt>.
      def verify_mode=(mode)
        raise ArgumentError, "Invalid SSL verify mode: #{mode}" unless VERIFY_MODES.include? mode
        @verify_mode = mode
      end

      # Returns an <tt>OpenSSL::X509::Certificate</tt> for the +cert_file+.
      def cert
        @cert ||= OpenSSL::X509::Certificate.new File.read(cert_file)
      end

      # Sets the +OpenSSL+ certificate.
      attr_writer :cert

      # Returns an <tt>OpenSSL::X509::Certificate</tt> for the +ca_cert_file+.
      def ca_cert
        @ca_cert ||= OpenSSL::X509::Certificate.new File.read(ca_cert_file)
      end

      # Sets the +OpenSSL+ ca certificate.
      attr_writer :ca_cert

      # Returns an <tt>OpenSSL::PKey::RSA</tt> for the +cert_key_file+.
      def cert_key
        @cert_key ||= OpenSSL::PKey::RSA.new(File.read(cert_key_file), cert_key_password)
      end

      # Sets the +OpenSSL+ certificate key.
      attr_writer :cert_key

      # Returns the SSL verify mode as a <tt>OpenSSL::SSL::VERIFY_*</tt> constant.
      def openssl_verify_mode
        case verify_mode
          when :none                 then OpenSSL::SSL::VERIFY_NONE
          when :peer                 then OpenSSL::SSL::VERIFY_PEER
          when :fail_if_no_peer_cert then OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
          when :client_once          then OpenSSL::SSL::VERIFY_CLIENT_ONCE
        end
      end

    end
  end
end
