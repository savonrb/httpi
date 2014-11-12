require "spec_helper"
require "httpi/auth/ssl"

describe HTTPI::Auth::SSL do
  before(:all) do
    @ssl_versions = OpenSSL::SSL::SSLContext::METHODS.reject { |method| method.match /server|client/ }.sort.reverse
  end

  describe "VERIFY_MODES" do
    it "contains the supported SSL verify modes" do
      expect(HTTPI::Auth::SSL::VERIFY_MODES).to eq([:none, :peer, :fail_if_no_peer_cert, :client_once])
    end
  end

  describe "#present?" do
    it "defaults to return false" do
      ssl = HTTPI::Auth::SSL.new
      expect(ssl).not_to be_present
    end

    it "returns false if only a client key was specified" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert_key_file = "spec/fixtures/client_key.pem"

      expect(ssl).not_to be_present
    end

    it "returns false if only a client key was specified" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert_file = "spec/fixtures/client_cert.pem"

      expect(ssl).not_to be_present
    end

    it "returns true if both client key and cert are present" do
      expect(ssl).to be_present
    end

    it "returns true of the verify_mode is :none" do
      ssl = HTTPI::Auth::SSL.new
      ssl.verify_mode = :none
      expect(ssl).to be_present
    end
  end

  describe "#verify_mode" do
    it "defaults to return :peer" do
      expect(ssl.verify_mode).to eq(:peer)
    end

    it "sets the verify mode to use" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :none
      expect(ssl.verify_mode).to eq(:none)
    end

    it "raises an ArgumentError if the given mode is not supported" do
      expect { ssl.verify_mode = :invalid }.
        to raise_error(ArgumentError, "Invalid SSL verify mode :invalid\n" +
                                      "Please specify one of [:none, :peer, :fail_if_no_peer_cert, :client_once]")
    end
  end

  describe "#cert" do
    it "returns an OpenSSL::X509::Certificate for the given cert_file" do
      expect(ssl.cert).to be_a(OpenSSL::X509::Certificate)
    end

    it "returns nil if no cert_file was given" do
      ssl = HTTPI::Auth::SSL.new
      expect(ssl.cert).to be_nil
    end

    it "returns the explicitly given certificate if set" do
      ssl = HTTPI::Auth::SSL.new
      cert = OpenSSL::X509::Certificate.new
      ssl.cert = cert
      expect(ssl.cert).to eq(cert)
    end
  end

  describe "#cert_key" do
    it "returns a OpenSSL::PKey::RSA for the given cert_key" do
      expect(ssl.cert_key).to be_a(OpenSSL::PKey::RSA)
    end

    it "returns nil if no cert_key_file was given" do
      ssl = HTTPI::Auth::SSL.new
      expect(ssl.cert_key).to be_nil
    end

    it "returns the explicitly given key if set" do
      ssl = HTTPI::Auth::SSL.new
      key = OpenSSL::PKey::RSA.new
      ssl.cert_key = key
      expect(ssl.cert_key).to eq(key)
    end
  end

  describe "#ca_cert" do
    it "returns an OpenSSL::X509::Certificate for the given ca_cert_file" do
      ssl = HTTPI::Auth::SSL.new

      ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
      expect(ssl.ca_cert).to be_a(OpenSSL::X509::Certificate)
    end
  end

  describe "#openssl_verify_mode" do
    it "returns the OpenSSL verify mode for :none" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :none
      expect(ssl.openssl_verify_mode).to eq(OpenSSL::SSL::VERIFY_NONE)
    end

    it "returns the OpenSSL verify mode for :peer" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :peer
      expect(ssl.openssl_verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER)
    end

    it "returns the OpenSSL verify mode for :fail_if_no_peer_cert" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :fail_if_no_peer_cert
      expect(ssl.openssl_verify_mode).to eq(OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT)
    end

    it "returns the OpenSSL verify mode for :client_once" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :client_once
      expect(ssl.openssl_verify_mode).to eq(OpenSSL::SSL::VERIFY_CLIENT_ONCE)
    end
  end

  describe "SSL_VERSIONS" do
    it "contains the supported SSL versions" do
      expect(HTTPI::Auth::SSL::SSL_VERSIONS).to eq(@ssl_versions)
    end
  end

  describe "#ssl_version" do
    subject { HTTPI::Auth::SSL.new }

    it "returns the SSL version" do
      subject.ssl_version = @ssl_versions.first
      expect(subject.ssl_version).to eq(@ssl_versions.first)
    end

    it 'raises ArgumentError if the version is unsupported' do
      expect { ssl.ssl_version = :ssl_fail }.
        to raise_error(ArgumentError, "Invalid SSL version :ssl_fail\n" +
                                      "Please specify one of #{@ssl_versions}")
    end
  end

  def ssl
    ssl = HTTPI::Auth::SSL.new
    ssl.cert_key_file = "spec/fixtures/client_key.pem"
    ssl.cert_file = "spec/fixtures/client_cert.pem"
    ssl
  end

end
